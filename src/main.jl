using TOML
include("core.jl")
include("io.jl")

function main()
    #設定を読み込む
    config = TOML.parsefile("configs/config.toml")
    L = config["system"]["L"]
    j = config["system"]["j"]
    delta = config["system"]["delta"]
    total_Sz = config["system"]["total_Sz"]

    nsweeps = config["simulation"]["nsweeps"]
    maxdim = config["simulation"]["maxdim"]
    cutoff = config["simulation"]["cutoff"]

    base_dir = config["io"]["base_dir"]

    filename = create_csv_filename(L, j, delta, total_Sz, base_dir)

    if total_Sz == 90
        factor = 0.5
    elseif total_Sz == 10
        factor = 2.0
    else
        factor = 1.0
    end

    # DMRG計算
    _, psi0 = dmrg_gs_xxz_ladder(L, j, delta, total_Sz; nsweeps, maxdim, cutoff)
    # 各サイトのSzを計算
    Szs = calc_Szs(psi0, L)
    # 相関関数を計算
    corr_xxs = calc_xx(psi0, L, factor)
    corr_zzs = calc_zz(psi0, L)
    # 結果をCSVファイルに保存
    result_to_csv(Szs, corr_xxs, corr_zzs, filename)
end