import cadquery as cq

# from cadquery import Workplane, Sketch, Vector, Location
# s1 = (
#      Sketch()
#      .importDXF(filename="master.dxf", exclude=[
#         "0",
#         "above_plate_void",
#         "base",
#         "below_plate_void",
#         "case_holes",
#         "mcu_cover",
#         "plate",
#         "plate_holes",
#         "switch_holes",
#     ])
# )

(L, w, t) = (20.0, 6.0, 3.0)
s = cq.Workplane("XY")

# Draw half the profile of the bottle and extrude it
p = (
    s.center(-L/2.0, 0)
    .vLine(w/2.0)
    .threePointArc((L/2.0, w/2.0 + t), (L, w/2.0))
    .vLine(-w/2.0)
    .mirrorX()
    .extrude(30.0, True)
    )

# Make the neck
p = (
    p.faces(">Z")
    .workplane(centerOption="CenterOfMass")
    .circle(3.0)
    .extrude(2.0, True)
)

# Make a shell
# result = p.faces(">Z").shell(0.3)