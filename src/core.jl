using ITensors, ITensorMPS
include("utils.jl")

function dmrg_gs_xxz(L::Int, J::Float64 , delta::Float64, total_Sz::Int64 ; nsweeps::Int = 20, maxdim::Vector{Int} = [200], cutoff::Vector{Float64} = [1E-10])
    if isodd(L)
        error("L must be even")
    end

    sites = siteinds("S=1/2",L; conserve_qns = true)#量子数保存

    #ハミルトニアンを構築
    local os = OpSum()
    for j=1:L-1
        os += J * delta, "Sz", j+1, "Sz", j
        os += J/2      , "S+", j+1, "S-", j
        os += J/2      , "S-", j+1, "S+", j
    end
    H = MPO(os,sites)

    state     = make_states(L, total_Sz) 
    psi0_init = random_mps(sites, state)

    energy, psi0 = dmrg(H,psi0_init;
        nsweeps,
        maxdim,
        cutoff
    )

    return energy, psi0
end

function dmrg_gs_xxz_ladder(L::Int, j::Float64, delta::Float64, total_Sz::Int64 ; nsweeps::Int = 20, maxdim::Vector{Int} = [200], cutoff::Vector{Float64} = [1E-10])
    J_ver = j 
    J_par = 1.0
    sites = siteinds("S=1/2", 2L; conserve_qns = true)
    local os = OpSum()
    #垂直方向の相互作用
    for j = 1:L
        os += J_ver * delta, "Sz", 2j-1, "Sz", 2j
        os +=   0.5 * J_ver, "S+", 2j-1, "S-", 2j
        os +=   0.5 * J_ver, "S-", 2j-1, "S+", 2j
    end

    #平行方向の相互作用
    for j = 1:L-1
        #奇数サイト同士の相互作用
        os += J_par * delta, "Sz", 2j-1, "Sz", 2j+1
        os +=   0.5 * J_par, "S+", 2j-1, "S-", 2j+1
        os +=   0.5 * J_par, "S-", 2j-1, "S+", 2j+1

        #偶数サイト同士の相互作用
        os += J_par * delta, "Sz", 2j, "Sz", 2j+2
        os +=   0.5 * J_par, "S+", 2j, "S-", 2j+2
        os +=   0.5 * J_par, "S-", 2j, "S+", 2j+2
    end

    #端の磁場
    h_prime = J_par * delta / 4.0
    os += h_prime, "Sz", 1
    os += h_prime, "Sz", 2
    os += h_prime, "Sz", 2L-1
    os += h_prime, "Sz", 2L

    H = MPO(os,sites)

    state     = make_states(2L, total_Sz) 
    psi0_init = random_mps(sites, state)

    energy, psi0 = dmrg(H,psi0_init;
        nsweeps,
        maxdim,
        cutoff
    )

    return energy, psi0
end

function calc_corre_funcs(psi::MPS)
    L  = length(psi)
    corr_xxs = Float64[]
    corr_zzs = Float64[]
    corr_pp = correlation_matrix(psi, "S+", "S+")
    corr_pm = correlation_matrix(psi, "S+", "S-")
    corr_mp = correlation_matrix(psi, "S-", "S+")
    corr_mm = correlation_matrix(psi, "S-", "S-")
    corr_xx_matrix = (corr_pp + corr_pm + corr_mp + corr_mm) / 4.0
    corr_zz_matrix = correlation_matrix(psi, "Sz", "Sz")
    for r in 0:L-1
        r0      = isodd(r) ? (L+1)/2 : L/2
        l       = floor(Int, r0 - r/2)
        l_prime = floor(Int, r0 + r/2)
        c_xx = corr_xx_matrix[l, l_prime]
        c_zz = corr_zz_matrix[l, l_prime]
        push!(corr_xxs, (-1)^abs(l-l_prime) * c_xx)
        push!(corr_zzs, abs(c_zz))
    end
    return corr_xxs, corr_zzs
end

function calc_Szs(psi::MPS, L::Int)
    Szs = expect(psi, "Sz")
    rung_Szs = Float64[]
    for l in 1:L
        S1z = Szs[transf_index(l, 1)]
        S2z = Szs[transf_index(l, 2)]
        push!(rung_Szs, abs(S1z + S2z))
    end
    return rung_Szs
end

function calc_zz(psi::MPS, L::Int)
    corr_zzs  = Float64[]
    zz_matrix = correlation_matrix(psi, "Sz", "Sz")
    for r in 0:L-1
        r0      = isodd(r) ? (L+1)/2 : L/2
        l       = floor(Int, r0 - r/2)
        l_prime = floor(Int, r0 + r/2)

        S1z_S1z = zz_matrix[transf_index(l, 1), transf_index(l_prime, 1)]
        S1z_S2z = zz_matrix[transf_index(l, 1), transf_index(l_prime, 2)]
        S2z_S1z = zz_matrix[transf_index(l, 2), transf_index(l_prime, 1)]
        S2z_S2z = zz_matrix[transf_index(l, 2), transf_index(l_prime, 2)]
        
        corr_zz = S1z_S1z + S1z_S2z + S2z_S1z + S2z_S2z
        push!(corr_zzs, abs(corr_zz))
    end
    return corr_zzs
end

function calc_xx(psi::MPS, L::Int, factor::Float64 = 1.0)
    corr_pp = correlation_matrix(psi, "S+", "S+")
    corr_pm = correlation_matrix(psi, "S+", "S-")
    corr_mp = correlation_matrix(psi, "S-", "S+")
    corr_mm = correlation_matrix(psi, "S-", "S-")
    corr_xx_matrix = (corr_pp + corr_pm + corr_mp + corr_mm) / 4.0
    return extract_corre_from_xx_matrix(corr_xx_matrix, L, factor)
end

function extract_corre_from_xx_matrix(xx_matrix::Matrix{Float64}, L::Int, factor::Float64 = 1.0)
    corr_xxs = Float64[]
    for r in 0:L-1
        r0      = isodd(r) ? (L+1)/2 : L/2
        l       = floor(Int, r0 - r/2)
        l_prime = floor(Int, r0 + r/2)
        S1x_S1x = xx_matrix[transf_index(l, 1), transf_index(l_prime, 1)]
        S1x_S2x = xx_matrix[transf_index(l, 1), transf_index(l_prime, 2)]
        S2x_S1x = xx_matrix[transf_index(l, 2), transf_index(l_prime, 1)]
        S2x_S2x = xx_matrix[transf_index(l, 2), transf_index(l_prime, 2)]
        corr_xx = S1x_S1x - S1x_S2x - S2x_S1x +S2x_S2x
        push!(corr_xxs, factor * (-1)^abs(l-l_prime) * corr_xx)
    end
    return corr_xxs
end