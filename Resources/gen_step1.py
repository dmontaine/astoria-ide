from PIL import Image, ImageDraw, ImageFilter
import math

SS = 4
BASE = 256
S = BASE * SS

def lerp(a, b, t):
    return a + (b - a) * t

def lerp_color(c1, c2, t):
    return tuple(int(lerp(c1[i], c2[i], t)) for i in range(3))

ROAD_GREY   = (150, 150, 150)

# Colors sampled from Logo.png, arranged as bands mimicking the photo's
# composition: a white top (now half its previous height), whose bottom half
# is a blue slightly darker than the water (the mountain band), then water.
SKY_WHITE      = (245, 250, 252)
WATER_BLUE     = (75, 155, 205)
WATER_DEEP     = (42, 112, 178)
MOUNTAIN_BLUE  = tuple(int(c * 0.8) for c in WATER_BLUE)  # slightly darker than the water
YELLOW_WARM    = (232, 202, 122)
YELLOW_OLIVE   = (150, 160, 78)

band_stops = [
    (0.00, SKY_WHITE),
    (0.04, SKY_WHITE),
    (0.045, MOUNTAIN_BLUE),   # bottom half of the (halved) white area
    (0.09, MOUNTAIN_BLUE),
    (0.11, WATER_BLUE),
    (1.00, WATER_DEEP),
]

def band_color(t):
    for i in range(len(band_stops) - 1):
        t0, c0 = band_stops[i]
        t1, c1 = band_stops[i + 1]
        if t0 <= t <= t1 or i == len(band_stops) - 2:
            local_t = 0 if t1 == t0 else (t - t0) / (t1 - t0)
            return lerp_color(c0, c1, max(0, min(1, local_t)))

img = Image.new("RGB", (S, S))
px = img.load()
for y in range(S):
    col = band_color(y / S)
    for x in range(S):
        px[x, y] = col
img = img.convert("RGBA")

# A small splash of green/yellow tucked in the lower-left corner only.
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse([S*0.0-S*0.30, S*1.0-S*0.30, S*0.0+S*0.30, S*1.0+S*0.30], fill=YELLOW_OLIVE + (190,))
glow = glow.filter(ImageFilter.GaussianBlur(S * 0.05))
img.alpha_composite(glow)

glow2 = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(glow2).ellipse([S*0.05-S*0.18, S*0.97-S*0.18, S*0.05+S*0.18, S*0.97+S*0.18], fill=YELLOW_WARM + (170,))
glow2 = glow2.filter(ImageFilter.GaussianBlur(S * 0.035))
img.alpha_composite(glow2)

radius_corner = int(S * 0.22)
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=radius_corner, fill=255)

def catmull_rom(points, steps_per_seg=60):
    pts = [points[0]] + points + [points[-1]]
    out = []
    for i in range(1, len(pts) - 2):
        p0, p1, p2, p3 = pts[i-1], pts[i], pts[i+1], pts[i+2]
        for s in range(steps_per_seg):
            t = s / steps_per_seg
            t2, t3 = t*t, t*t*t
            x = 0.5 * ((2*p1[0]) + (-p0[0]+p2[0])*t + (2*p0[0]-5*p1[0]+4*p2[0]-p3[0])*t2 + (-p0[0]+3*p1[0]-3*p2[0]+p3[0])*t3)
            y = 0.5 * ((2*p1[1]) + (-p0[1]+p2[1])*t + (2*p0[1]-5*p1[1]+4*p2[1]-p3[1])*t2 + (-p0[1]+3*p1[1]-3*p2[1]+p3[1])*t3)
            out.append((x, y))
    out.append(points[-1])
    return out

def N(x, y):
    return (x * S, y * S)

def stamped_stroke_layer(size, pts, radius_px, color, alpha=255):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    n = len(pts)
    for i in range(n - 1):
        x0, y0 = pts[i]
        x1, y1 = pts[i + 1]
        seg_len = math.hypot(x1 - x0, y1 - y0)
        steps = max(1, int(seg_len / max(1.0, radius_px * 0.35)))
        for k in range(steps):
            t = k / steps
            x = lerp(x0, x1, t)
            y = lerp(y0, y1, t)
            ld.ellipse([x - radius_px, y - radius_px, x + radius_px, y + radius_px], fill=color + (alpha,))
    return layer

# Road / causeway path traced from the original photo (Logo.png), normalized 0..1 coords,
# extended up past the bridge to just below the upper-left corner
road_anchors_raw = [
    (0.09, 0.11),
    (0.24, 0.16),
    (0.42, 0.24),
    (0.60, 0.35),
    (0.74, 0.48),
    (0.83, 0.58),
    (0.875, 0.68),
    (0.86, 0.78),
    (0.76, 0.86),
    (0.63, 0.92),
    (0.52, 0.965),
    (0.44, 1.02),
]
road_anchors = [N(x, y) for (x, y) in road_anchors_raw]
road_pts = catmull_rom(road_anchors, steps_per_seg=50)

W_ROAD = S * 0.017  # a little wider
ROAD_GREY = (95, 95, 95)  # a little darker

road_layer = stamped_stroke_layer((S, S), road_pts, W_ROAD, ROAD_GREY)
img.alpha_composite(road_layer)

# ---- Twin bridge towers, same aspect as measured from the original photo ----
# Measured from Logo.png (normalized 0..1): left peak (0.306,0.120), right peak
# (0.488,0.065), saddle (0.401,0.194), common base ~0.341 -> left height 0.221,
# right height 0.276, width 0.182 (right/left height ratio 1.25, width/left-height 0.82)
BRIDGE_GREEN      = (104, 166, 128)
BRIDGE_GREEN_DARK = (66, 122, 92)

def road_point_at_x(x_norm, search_pts):
    """Nearest point (within a given slice of the road curve) at a given normalized
    x, so bridge lines can terminate exactly on it instead of overlapping it."""
    target = x_norm * S
    return min(search_pts, key=lambda p: abs(p[0] - target))

# Restrict the search to the upper approach segment of the road (before it curves
# back on itself in the lower S-bend), so we don't match a point on the wrong branch.
road_upper_segment = road_pts[: len(road_pts) // 2]

height_left = 0.20   # a little larger than before (was 0.16)
height_right = height_left * 1.25
width = height_left * 0.82
left_base_x = 0.55    # positioned near the sweep/curve of the road
right_base_x = left_base_x + width
saddle_frac = 0.38   # deeper dip between the two towers (was 0.665)
saddle_x_frac = 0.522

left_base_pt  = road_point_at_x(left_base_x, road_upper_segment)
right_base_pt = road_point_at_x(right_base_x, road_upper_segment)
left_base_y   = left_base_pt[1] / S
right_base_y  = right_base_pt[1] / S

left_peak  = (left_base_x, left_base_y - height_left)
right_peak = (right_base_x, right_base_y - height_right)
saddle     = (left_base_x + saddle_x_frac * width,
              left_base_y - saddle_frac * height_left)

cable_start = road_point_at_x(left_base_x - 0.09, road_upper_segment)
cable_end   = road_point_at_x(right_base_x + 0.09, road_upper_segment)

tower_cable_anchors = [
    cable_start,             # ends exactly on the grey road line, no overlap
    N(*left_peak),
    N(*saddle),
    N(*right_peak),
    cable_end,                # ends exactly on the grey road line, no overlap
]
tower_cable_pts = catmull_rom(tower_cable_anchors, steps_per_seg=50)

W_TOWER_CABLE = S * 0.018
W_TOWER_LEG   = S * 0.015

cable_layer = stamped_stroke_layer((S, S), tower_cable_pts, W_TOWER_CABLE, BRIDGE_GREEN)
img.alpha_composite(cable_layer)

for peak, base_pt in [(left_peak, left_base_pt), (right_peak, right_base_pt)]:
    leg_layer = stamped_stroke_layer((S, S), [N(*peak), base_pt], W_TOWER_LEG, BRIDGE_GREEN_DARK)
    img.alpha_composite(leg_layer)

img.putalpha(mask)

final = img.resize((BASE, BASE), Image.LANCZOS)
final.save("astoria_step1_preview.png")
sizes = [16, 24, 32, 48, 64, 128, 256]
final.save("AstoriaIDE_step1.ico", sizes=[(s, s) for s in sizes])

grid = Image.new("RGBA", (16*4+24*4+32*4+48*4+40, 48*4), (40,40,40,255))
x = 0
for s in [16,24,32,48]:
    thumb = final.resize((s,s), Image.LANCZOS)
    big = thumb.resize((s*4,s*4), Image.NEAREST)
    grid.paste(big, (x,0))
    x += s*4 + 10
grid.save("step1_size_check.png")
print("done")
