"""
    from_a_b(a::Integer, b::Integer, rnd::RoundingMode = RoundNearest; prec = precision(Arf), verbose::Bool = false)

Return the `Arf` value given by `a * 2^b` rounded to `prec` bits in
the direction specified by `rnd`.

If `verbose` is true then log a message if the result was rounded,
i.e. if the result was not exactly representable in the specified
precision.

Note that for if `a` is even then [`from_a_b`](@ref) will not recover
exactly `a` and `b`.
"""
function from_a_b(
    a::Integer,
    b::Integer,
    rnd::RoundingMode = RoundNearest;
    prec = precision(Arf),
    verbose::Bool = false,
)
    x = Arf(; prec)
    flag = Arblib.set_round!(x, a; prec, rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    Arblib.mul_2exp!(x, x, b) # Note that this is exact, no rounding is done
    return x
end

"""
    to_a_b(x::Arf)

Return `a, b` such that `a * 2^b = x`.
"""
function to_a_b(x::Arf)
    a = Arblib.fmpz_struct()
    b = Arblib.fmpz_struct()
    ccall(
        Arblib.@libflint(arf_get_fmpz_2exp),
        Cvoid,
        (Ref{Arblib.fmpz_struct}, Ref{Arblib.fmpz_struct}, Ref{Arblib.arf_struct}),
        a,
        b,
        x,
    )
    return BigInt(a), BigInt(b)
end

"""
    add_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)

Compute `x + y` rounded according to `rnd`. If `verbose` is true then
log a message if the result was rounded.
"""
function add_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)
    res = zero(x)
    flag = Arblib.add!(res, x, y; rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    return res
end

"""
    sub_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)

Compute `x - y` rounded according to `rnd`. If `verbose` is true then
log a message if the result was rounded.
"""
function sub_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)
    res = zero(x)
    flag = Arblib.sub!(res, x, y; rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    return res
end

"""
    mul_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)

Compute `x * y` rounded according to `rnd`. If `verbose` is true then
log a message if the result was rounded.
"""
function mul_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)
    res = zero(x)
    flag = Arblib.mul!(res, x, y; rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    return res
end

"""
    div_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)

Compute `x / y` rounded according to `rnd`. If `verbose` is true then
log a message if the result was rounded.
"""
function div_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)
    res = zero(x)
    flag = Arblib.div!(res, x, y; rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    return res
end

"""
    fma_rnd(x::Arf, y::Arf, rnd::RoundingMode; verbose::Bool = false)

Compute `x * y + z` rounded (once) according to `rnd`. If `verbose` is
true then log a message if the result was rounded.
"""
function fma_rnd(x::Arf, y::Arf, z::Arf, rnd::RoundingMode; verbose::Bool = false)
    res = zero(x)
    flag = Arblib.fma!(res, x, y, z; rnd)
    verbose && !iszero(flag) && @info "Rounded!"
    return res
end
