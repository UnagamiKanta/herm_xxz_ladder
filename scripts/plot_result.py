import matplotlib.pyplot as plt
import csv

base_dir = "datas/"

keys = ["010", "050", "090"]

j = "_j01"

rs  = [i for i in range(100)]
ls  = [i for i in range(1, 101)]

sz_datas  = {"010": None, "050":None, "090":None}
czz_datas = {"010": None, "050":None, "090":None}
cxx_datas = {"010": None, "050":None, "090":None}

for key in keys:
    szs  = []
    czzs = []
    cxxs = []

    with open(base_dir + key + j + ".csv") as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # ヘッダーをスキップ
        for row in reader:
            cxxs.append(float(row[1]))
            szs.append(float(row[0]))
            czzs.append(float(row[2]))

    sz_datas[key] = szs
    czz_datas[key] = czzs
    cxx_datas[key] = cxxs

plt.figure()
plt.plot(ls, sz_datas["010"], "-ob", label="Sz=0.10", markersize=3)
plt.plot(ls, sz_datas["050"], "-sg", label="Sz=0.50", markersize=3)
plt.plot(ls, sz_datas["090"], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Sz")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-2, 1.5)
plt.title("Sz vs R")
plt.legend()
plt.savefig("datas/images/sz_"+ j +".png")

plt.figure()
plt.plot(rs, czz_datas["010"], "-ob", label="Sz=0.10", markersize=3)
plt.plot(rs, czz_datas["050"], "-sg", label="Sz=0.50", markersize=3)
plt.plot(rs, czz_datas["090"], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Czz")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-4, 1.5)
plt.title("Czz vs R")
plt.legend()
plt.savefig("datas/images/czz_"+j+".png")

plt.figure()
plt.plot(rs, cxx_datas["010"], "-ob", label="Sz=0.10", markersize=3)
plt.plot(rs, cxx_datas["050"], "-sg", label="Sz=0.50", markersize=3)
plt.plot(rs, cxx_datas["090"], "-^r", label="Sz=0.90", markersize=3)
plt.xlabel("R")
plt.ylabel("Cxx")
plt.yscale("log")
plt.xlim(0, 100)
plt.ylim(1e-3, 1)
plt.title("Cxx vs R")
plt.legend()
plt.savefig("datas/images/cxx_"+j+".png")