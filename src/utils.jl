using Random # shuffle! を使うために必要
using Dates

function make_states(L::Int, total_Sz::Int64)
    # total_Szの計算は2Lのサイト数に対して行われるため、
    # 呼び出し側で dmrg_gs_xxz_ladder の 2L を渡していることを想定
    # この関数内での L は全サイト数
    if isodd(L + 2*total_Sz)
        error("L and 2*total_Sz must have the same parity.")
    end
    
    num_up = div(L, 2) + total_Sz

    if num_up > L || num_up < 0
        error("invalid total Sz")
    end
    
    # "Up"と"Dn"を必要数だけ持つ配列を作成
    state = vcat(fill("Up", num_up), fill("Dn", L - num_up))
    
    shuffle!(state)
    
    return state
end

function transf_index(l::Int, mu::Int)
    return 2(l-1) + mu
end

function transf_corp(i::Int)
    if isodd(i)
        l = floor((i-1)/2)
        mu = 1
    else
        l = floor(i/2)
        mu = 0
    end
    return l, mu
end

function create_csv_filename(L::Int, j::Float64, delta::Float64, total_Sz::Int64, base_dir::String = "results/")
    # 現在の日時を取得
    current_time = Dates.now()
    # 日時をフォーマット
    formatted_time = Dates.format(current_time, "yyyymmddHHMMSS")
    # ファイル名を生成
    filename = base_dir * "L$(L)_j$(j)_delta$(delta)_Sz$(total_Sz)_$(formatted_time).csv"
    return filename
    
end