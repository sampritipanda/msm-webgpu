struct JacobianPoint {
    x: BaseField,
    y: BaseField,
    z: BaseField
};

fn jacobian_double(p: JacobianPoint) -> JacobianPoint {
    if (field_eq(p.y, ZERO)) {
        return JacobianPoint(ZERO, ZERO, ZERO);
    }

    let ysq = field_pow(p.y, 2);
    let S = field_small_scalar_mul(4, field_mul(p.x, ysq));
    let M = field_small_scalar_mul(3, field_pow(p.x, 2)); // assumes a = 0, sw curve
    let nx = field_sub(field_pow(M, 2), field_small_scalar_mul(2, S));
    let ny = field_sub(field_mul(M, field_sub(S, nx)), field_small_scalar_mul(8, field_pow(ysq, 2)));
    let nz = field_mul(field_small_scalar_mul(2, p.y), p.z);
    return JacobianPoint(nx, ny, nz);
}

fn jacobian_add(p: JacobianPoint, q: JacobianPoint) -> JacobianPoint {
    if (field_eq(p.y, ZERO)) {
        return q;
    }
    if (field_eq(q.y, ZERO)) {
        return p;
    }

    let U1 = field_mul(p.x, field_pow(q.z, 2));
    let U2 = field_mul(q.x, field_pow(p.z, 2));
    let S1 = field_mul(p.y, field_pow(q.z, 3));
    let S2 = field_mul(q.y, field_pow(p.z, 3));
    if (field_eq(U1, U2)) {
        if (field_eq(S1, S2)) {
            return jacobian_double(p);
        } else {
            return JacobianPoint(ZERO, ZERO, ONE);
        }
    }

    let H = field_sub(U2, U1);
    let R = field_sub(S2, S1);
    let H2 = field_mul(H, H);
    let H3 = field_mul(H2, H);
    let U1H2 = field_mul(U1, H2);
    let nx = field_sub(field_sub(field_pow(R, 2), H3), field_small_scalar_mul(2, U1H2));
    let ny = field_sub(field_mul(R, field_sub(U1H2, nx)), field_mul(S1, H3));
    let nz = field_mul(field_mul(H, p.z), q.z);
    return JacobianPoint(nx, ny, nz);
}

fn jacobian_mul(p: JacobianPoint, k: ScalarField) -> JacobianPoint {
    var r: JacobianPoint = JacobianPoint(ZERO, ZERO, ONE);
    var t: JacobianPoint = p;
    for (var i = 0u; i < N; i = i + 1u) {
        var k_s = k.limbs[i];
        for (var j = 0u; j < W; j = j + 1u) {
            if ((k_s & 1) == 1u) {
                r = jacobian_add(r, t);
            }
            t = jacobian_double(t);
            k_s = k_s >> 1;
        }
    }
    return r;
}
