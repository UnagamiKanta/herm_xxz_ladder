using TOML
#設定を読み込む
config = TOML.parsefile("configs/config.toml")
L = config["system"]["L"]
J = config["system"]["J"]
delta = config["system"]["delta"]
h     = config["system"]["h"]
total_Sz = config["system"]["total_Sz"]
eta

function f(alpha, x) 
    return (2(L + 1)/pi * sin(pi * abs(x) / 2 /(L+1)))^alpha
end

function X(l, l_prime, q)

end