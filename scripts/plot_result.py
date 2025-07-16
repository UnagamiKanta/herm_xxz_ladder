import csv
import matplotlib.pyplot as plt
import datetime

class Config:
    def __init__(self):
        self.pathes = {
                        10 : "datas\csvs\L100_j1.0_delta1.0_Sz10_20250716111017.csv",
                        50 : "datas\csvs\L100_j1.0_delta1.0_Sz50_20250716111928.csv",
                        90 : "datas\csvs\L100_j1.0_delta1.0_Sz90_20250716112235.csv"
                    }
        self.output_base_dir = "datas/images/"
        self.j      = 1.0
        self.delta  = 1.0
        self.L      = 100

def output_dir(base_dir, L, j, delta,physical_value):
    j_str = str(int(j)).zfill(3)
    delta_str = str(int(delta * 10)).zfill(3)
    return f"{base_dir}{physical_value}_L{L}_j{j_str}_delta{delta_str}_{str(datetime.datetime)}.png"
    
rs  = [i for i in range(100)]
ls  = [i for i in range(1, 101)]

sz_datas  = {10: None, 50:None, 90:None}
czz_datas = {10: None, 50:None, 90:None}
cxx_datas = {10: None, 50:None, 90:None}

for key in Config().pathes.keys():
    szs  = []
    czzs = []
    cxxs = []

    with open(Config().pathes[key], 'r') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            szs.append(float(row[0]))
            czzs.append(float(row[2]))
            cxxs.append(float(row[1]))

    sz_datas[key] = szs
    czz_datas[key] = czzs
    cxx_datas[key] = cxxs


plt.figure()
plt.plot(ls, sz_datas[10], "-ob", label="Sz=0.10", markersize=3)
plt.plot(ls, sz_datas[50], "-sg", label="Sz=0.50", markersize=3)
plt.plot(ls, sz_datas[90], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Sz")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-2, 1.5)
plt.title("Sz vs R")
plt.legend()
plt.savefig("datas/images/sz_"+str(Config().j)+".png")

plt.figure()
plt.plot(rs, czz_datas[10], "-ob", label="Sz=0.10", markersize=3)
plt.plot(rs, czz_datas[50], "-sg", label="Sz=0.50", markersize=3)
plt.plot(rs, czz_datas[90], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Czz")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-4, 1.5)
plt.title("Czz vs R")
plt.legend()
plt.savefig("datas/images/czz_"+str(Config().j)+".png")

plt.figure()
plt.plot(rs, cxx_datas[10], "-ob", label="Sz=0.10", markersize=3)
plt.plot(rs, cxx_datas[50], "-sg", label="Sz=0.50", markersize=3)
plt.plot(rs, cxx_datas[90], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Cxx")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-3, 1)
plt.title("Cxx vs R")
plt.legend()
plt.savefig("datas/images/cxx_"+str(Config().j)+".png")