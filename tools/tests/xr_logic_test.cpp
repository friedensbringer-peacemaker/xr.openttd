/*
 * Host tests for the header-only VR logic of XR-OpenTTD (no Quest needed):
 * screen pose, ray/screen intersection (flat and curved), controller input helpers and the pointer offset.
 *
 *   tools/tests/run.sh
 */
#include "../../engine/OpenTTD/src/video/xr/xr_input.h"
#include "../../engine/OpenTTD/src/video/xr/xr_panel.h"
#include "../../engine/OpenTTD/src/video/xr/xr_pointer_offset.h"

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <limits>

static int _failures = 0;

static void Check(bool ok, const char *what)
{
	if (!ok) {
		std::printf("FAIL: %s\n", what);
		++_failures;
	}
}

static bool Near(float a, float b, float eps = 1e-4f) { return std::fabs(a - b) <= eps; }

/* Screen point for (u, v) exactly as the driver computes the ray end (xr_v.cpp). */
static vrPanel::Vec3 ScreenPoint(float u, float v, float width, float aspect, float panel_z, float arc)
{
	float px = (u - .5f) * width, pz = panel_z;
	if (arc > 0.f) {
		const float radius = width / arc, theta = (u - .5f) * arc;
		px = radius * std::sin(theta);
		pz += radius * (1.f - std::cos(theta));
	}
	return {px, (.5f - v) * width * aspect, pz};
}

static void TestPoseRoundTrip()
{
	const vrPanel::Pose pose{{.3f, 1.6f, -.2f}, .7f, -1.8f, 0.f, .2f};
	const vrPanel::Vec3 p{.5f, -.25f, -1.3f};
	const auto back = pose.toLocal(pose.toWorld(p));
	Check(Near(back.x, p.x) && Near(back.y, p.y) && Near(back.z, p.z), "pose toWorld/toLocal round trip");
}

static vrPanel::Vec3 Normalise(vrPanel::Vec3 v)
{
	const float len = std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	return {v.x / len, v.y / len, v.z / len};
}

static int _hits = 0, _misses = 0;

/*
 * Sweep over the same path as the driver: screen point → world (Pose::toWorld) → ray from a hand
 * in world space → back to screen space (toLocal / directionToLocal) → intersect() → u, v.
 */
static void TestHitSweep()
{
	const float aspects[] = {9.f / 16.f, 10.f / 16.f, 3.f / 4.f, 9.f / 21.f, 1.f};
	const vrPanel::Pose poses[] = {
		{{0.f, 1.6f, 0.f}, 0.f, -1.8f, 0.f, 0.f},
		{{.4f, 1.5f, -.3f}, 1.1f, -1.2f, 0.f, .2f},
		{{-.2f, 1.7f, .5f}, -2.4f, -3.f, 0.f, -.4f},
	};
	for (float aspect : aspects) {
		for (int curvature = 0; curvature <= 2; ++curvature) {
			const float arc = vrPanel::angle(curvature);
			for (const auto &pose : poses) {
				const float width = 2.4f;
				for (const vrPanel::Vec3 hand_local : {vrPanel::Vec3{.25f, -.3f, -.1f}, vrPanel::Vec3{-.3f, -.5f, .1f}}) {
					const auto hand = pose.toWorld(hand_local);
					for (float u : {.02f, .3f, .5f, .7f, .98f}) {
						for (float v : {.02f, .5f, .97f}) {
							const auto target = pose.toWorld(ScreenPoint(u, v, width, aspect, pose.centerZ, arc));
							const auto dir = Normalise({target.x - hand.x, target.y - hand.y, target.z - hand.z});
							vrPanel::Hit hit;
							const bool ok = vrPanel::intersect(pose.toLocal(hand), pose.directionToLocal(dir), width, width * aspect, pose.centerZ, arc, hit);
							char what[160];
							std::snprintf(what, sizeof(what), "hit aspect=%.2f curvature=%d yaw=%.1f u=%.2f v=%.2f (got %d %.4f %.4f)",
								aspect, curvature, pose.yaw, u, v, ok, hit.u, hit.v);
							Check(ok && Near(hit.u, u, 1e-3f) && Near(hit.v, v, 1e-3f), what);
							++_hits;
						}
					}
				}
				/* Misses: backwards, parallel to the screen, above, beside. */
				const vrPanel::Vec3 origin{0.f, 0.f, 0.f};
				vrPanel::Hit hit;
				const vrPanel::Vec3 rays[][2] = {
					{origin, {0.f, 0.f, 1.f}},
					{origin, {1.f, 0.f, 0.f}},
					{{0.f, width * aspect, 0.f}, {0.f, 0.f, -1.f}},
					{{width * 1.5f, 0.f, 0.f}, {0.f, 0.f, -1.f}},
				};
				for (const auto &ray : rays) {
					Check(!vrPanel::intersect(ray[0], ray[1], width, width * aspect, pose.centerZ, arc, hit), "ray outside the screen must miss");
					++_misses;
				}
			}
		}
	}
}

static void TestInput()
{
	Check(vrInput::stickAxis(.2f) == 0.f, "stick deadzone");
	Check(Near(vrInput::stickAxis(1.f), 1.f) && Near(vrInput::stickAxis(-1.f), -1.f), "stick full deflection");

	/* Diagonal must not be faster than straight. */
	vrInput::PanAccumulator straight, diagonal;
	int sx = 0, sy = 0, dx = 0, dy = 0, total_s = 0, total_d = 0;
	for (int i = 0; i < 100; ++i) {
		straight.sample(1.f, 0.f, .01f, 0, false, sx, sy);
		diagonal.sample(1.f, 1.f, .01f, 0, false, dx, dy);
		total_s += sx;
		total_d += dx;
	}
	Check(total_d < total_s, "diagonal pan normalised");
	Check(std::abs(total_s - 200) <= 2, "pan speed 200 px/s at 1x");

	/* Short press fires on release when a long action exists; long press only once. */
	vrInput::ButtonGesture g;
	Check(g.sample(true, true, 0, 1, 2) == 0, "gesture: no action on press with long action");
	Check(g.sample(false, true, 100, 1, 2) == 1, "gesture: short action on release");
	Check(g.sample(true, true, 1000, 1, 2) == 0, "gesture: press again");
	Check(g.sample(true, true, 1700, 1, 2) == 2, "gesture: long action after 0.6 s");
	Check(g.sample(false, true, 1800, 1, 2) == 0, "gesture: no short action after long");

	/* Zoom repeat: first step at once, then after 450 ms, then every 250 ms. */
	vrInput::ZoomRepeat z;
	Check(z.sample(.9f, true, 0) == 1, "zoom first step");
	Check(z.sample(.9f, true, 300) == 0, "zoom waits");
	Check(z.sample(.9f, true, 460) == 1, "zoom repeat");
	Check(z.sample(.3f, true, 500) == 0, "zoom below threshold");
}

static int _offset_cases = 0;

/* Pointer offset X/Y (VR tab "Zeiger waagerecht/senkrecht"): raster, limits, NaN, stored steps, UV shift. */
static void TestPointerOffset()
{
	Check(ptroff::clampPercent(std::numeric_limits<float>::quiet_NaN()) == 0.f, "offset: NaN -> 0");
	Check(ptroff::clampPercent(std::numeric_limits<float>::infinity()) == 0.f, "offset: Inf -> 0");
	Check(ptroff::clampPercent(1.3f) == 1.25f, "offset: rounded to 0.25 raster");
	Check(ptroff::clampPercent(99.f) == 15.f && ptroff::clampPercent(-99.f) == -15.f, "offset: clamped to +-15 %");
	Check(!std::signbit(ptroff::clampPercent(-0.1f)), "offset: no -0");
	Check(ptroff::stepPercent(15.f, 1) == 15.f && ptroff::stepPercent(-15.f, -1) == -15.f, "offset: step stops at the limit");
	Check(ptroff::clampSteps(1000) == 60 && ptroff::clampSteps(-1000) == -60, "offset: stored steps clamped (xr.cfg)");
	Check(ptroff::displaySign(0) == 0 && ptroff::displaySign(5) == 1 && ptroff::displaySign(-2) == -1, "offset: display sign");
	Check(ptroff::displayHundredths(5) == 125 && ptroff::displayHundredths(-2) == 50, "offset: display +1,25 / -0,50");
	Check(ptroff::apply(.5f, 0.f) == .5f, "offset: 0 leaves the UV unchanged");

	/* Sweep: every stored step and stepping both ways round-trips; apply shifts by p/100 and stays in 0..1. */
	for (int steps = -ptroff::kMaxSteps - 5; steps <= ptroff::kMaxSteps + 5; ++steps) {
		const int clamped = ptroff::clampSteps(steps);
		const float p = ptroff::stepsToPercent(steps);
		Check(ptroff::percentToSteps(p) == clamped, "offset: steps <-> percent round trip");
		Check(ptroff::percentToSteps(ptroff::stepPercent(p, 1)) == std::min(clamped + 1, ptroff::kMaxSteps), "offset: > one step");
		Check(ptroff::percentToSteps(ptroff::stepPercent(p, -1)) == std::max(clamped - 1, -ptroff::kMaxSteps), "offset: < one step");
		for (int i = 0; i <= 20; ++i) {
			const float uv = i / 20.f;
			const float shifted = ptroff::apply(uv, p);
			Check(shifted >= 0.f && shifted <= 1.f, "offset: UV stays on the image");
			Check(Near(shifted, std::clamp(uv + p / 100.f, 0.f, 1.f), 1e-6f), "offset: UV shifted by p/100");
			if (p > 0.f) Check(shifted >= uv, "offset: positive = right/down");
			if (p < 0.f) Check(shifted <= uv, "offset: negative = left/up");
			++_offset_cases;
		}
	}
}

/* Hold-to-repeat of the < > buttons: first repeat after 450 ms, then every 120 ms, for any frame time. */
static void TestHoldRepeat()
{
	for (unsigned frame = 1; frame <= 60; ++frame) {
		for (unsigned held_ms = 0; held_ms <= 3000; held_ms += 37) {
			ptroff::HoldRepeat r;
			r.start(1003);
			int steps = 0;
			unsigned t = 0;
			while (t + frame <= held_ms) {
				steps += r.advance(true, frame);
				t += frame;
			}
			const int expected = t < 450 ? 0 : 1 + static_cast<int>((t - 450) / 120);
			Check(steps == expected, "repeat: 450 ms, then every 120 ms");
			Check(r.active(), "repeat: active while held");
			Check(r.advance(false, frame) == 0 && !r.active(), "repeat: release stops");
			Check(r.advance(true, 1000) == 0, "repeat: nothing after stop");
			++_offset_cases;
		}
	}
	/* Holding from 0 to +15 % in 0.25 % steps: 60 steps = click + 59 repeats ≈ 0.45 + 58 × 0.12 s. */
	ptroff::HoldRepeat r;
	r.start(1);
	int offset = ptroff::percentToSteps(ptroff::stepPercent(0.f, 1));
	for (int ms = 0; ms < 10000; ms += 11) {
		for (int i = r.advance(true, 11); i > 0; --i) offset = ptroff::percentToSteps(ptroff::stepPercent(ptroff::stepsToPercent(offset), 1));
	}
	Check(offset == ptroff::kMaxSteps, "repeat: stops at +15 %");
}

int main()
{
	TestPoseRoundTrip();
	TestHitSweep();
	TestInput();
	TestPointerOffset();
	TestHoldRepeat();
	std::printf("%s: %d hits, %d misses, %d pointer offset cases checked, %d failures\n", _failures == 0 ? "OK" : "FAILED", _hits, _misses, _offset_cases, _failures);
	return _failures == 0 ? 0 : 1;
}
