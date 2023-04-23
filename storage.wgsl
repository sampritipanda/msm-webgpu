const WORKGROUP_SIZE = 64;
const NUM_INVOCATIONS = 4096;
const MSM_SIZE = WORKGROUP_SIZE * NUM_INVOCATIONS;

@group(0) @binding(0)
var<storage, read_write> points: array<JacobianPoint>;
@group(0) @binding(1)
var<storage, read_write> scalars: array<ScalarField>;
@group(0) @binding(2)
var<storage, read_write> result: array<JacobianPoint, NUM_INVOCATIONS>;
@group(0) @binding(3)
var<storage, read_write> mem: array<JacobianPoint, MSM_SIZE>;
