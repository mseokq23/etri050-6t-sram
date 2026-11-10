# etri050-6t-sram

ETRI 0.5 µm CMOS(마이칩, 내 칩 제작 서비스) 공정에서 오픈소스 툴만으로 6T SRAM을 설계하는 과정을 정리한 레포.
velog 시리즈 **MyChip 6T SRAM** 의 코드, 로그, 사진이 전부 여기 있음.

| 시리즈 | 내용 | 폴더 |
|---|---|---|
| 1부 (34편) | 6T 셀 1개 → 4 × 4 어레이 (시뮬레이션, 레이아웃, DRC / LVS, 기생 추출, GDS) | 레포 최상위 (`sch/`, `sim/`, `layout/`, `logs/`, `docs/`) |
| 2부 (32편) | 64 words × 4 bits SRAM 매크로 → 28핀 패드 프레임 칩 GDS | [`sram64x4/`](sram64x4/) (2부 파일은 전부 이 폴더 안) |

아래는 1부 내용이고, 2부는 [sram64x4/README.md](sram64x4/README.md)에 따로 정리함.

- 회로도: Xschem / 시뮬레이션: ngspice
- 레이아웃·DRC·추출: Magic / LVS: Netgen / GDS·공식 덱 DRC: KLayout
- 환경: GitHub Codespaces + IIC-OSIC-TOOLS 2026.10 (브라우저 noVNC 데스크톱)

| 결과 | 값 |
|---|---|
| 6T 셀 (W/L, µm) | PU 1.8/0.6, PD 3.6/0.6, PG 1.8/0.6 |
| 셀 크기 | 18.0 × 17.7 µm (60 × 59 λ) |
| Hold SNM / Read SNM (5 V) | 1.313 V / 0.621 V |
| Write trip V(BL) | 2.01 V |
| 셀 레이아웃 | Magic DRC 0, LVS 일치 |
| 4 × 4 어레이 | Magic DRC 0, KLayout 공식 덱 DRC 0, LVS 일치 |
| 어레이 post-layout | 4행 × 4비트 쓰기 → 읽기 모두 일치 |

## PDK(디자인 킷)

PDK는 이 레포에 넣지 않았음. 아래 링크에서 받으면 됨.

- ETRI 0.5 µm CMOS 오픈소스 디자인 킷: https://github.com/GoodKook/ETRI-0.5um-CMOS-MPW-Std-Cell-DK
- 내 칩 제작 서비스 안내(모아팹): https://moafab.kr/css/myPage/bussiness/myChip/info

`scripts/setup-etri050.sh`가 위 킷에서 필요한 폴더(tech, spice, scripts)만 `.pdk/`로 받아옴. `.pdk/`는 `.gitignore`에 들어 있어서 커밋되지 않음.

## 시작

1. 이 레포를 fork (그냥 열어보기만 할 거면 fork 없이 2번부터 해도 됨)
2. Code → Codespaces → Create codespace on main (2-core도 되고 4-core면 더 쾌적함)
3. 처음 만들 때 이미지(압축 풀면 약 17 GB) 받고 `scripts/setup-etri050.sh`가 자동으로 실행됨 (작업 끝나면 codespace 삭제해야 무료 저장 용량이 덜 깎임)
4. Ports 탭의 6080(EDA Desktop) → 브라우저에서 noVNC 데스크톱 접속 (비밀번호 `abc123`)
5. 새 터미널에서 점검

```bash
bash scripts/check-env.sh
```

로컬 Docker로 쓸 때는 VS Code Dev Containers로 이 폴더를 열면 같은 환경이 됨.

## 폴더

```
.devcontainer/   Codespaces 설정 (IIC-OSIC-TOOLS 2026.10, noVNC 6080)
scripts/         킷 받기, 단축 명령(magic-etri, etri-drc, etri-lvs ...), 점검, SNM·스윕·그래프
sch/             Xschem 회로도·심볼 (inv, inv_tb, sram6t, column)
sim/             ngspice 덱 (I-V, butterfly, write trip, 셀/어레이 트랜지언트)
layout/          Magic 명령 스크립트 (단계별 .tcl, 결과 .mag/.gds는 직접 만들어짐)
logs/            실행 로그
docs/img/        포스트에 쓴 사진 (폴더 번호 = 포스트 번호)
```

## 단축 명령 (scripts/etri050-env.sh)

| 명령 | 하는 일 |
|---|---|
| `magic-etri [cell]` | ETRI 기술 파일로 Magic |
| `xschem-etri [file.sch]` | 이 레포 xschemrc로 Xschem |
| `klayout-etri [file.gds]` | ETRI 레이어 색으로 KLayout |
| `etri-drc <cell>` | Magic DRC |
| `etri-lvs <cell> <sch.spice> [subckt]` | 추출 + Netgen LVS |
| `etri-pex <cell>` | 기생 C 포함 추출 → `<cell>_pex.spice` |
| `etri-gds <cell>` | ETRI 층 번호로 GDS 쓰기 |
| `etri-drc-klayout <file.gds>` | 킷의 KLayout DRC 덱 |

## 한 번에 다시 돌리기

```bash
cd sim
ngspice -b nmos_iv.spice
ngspice -b butterfly.spice && python3 ../scripts/snm.py butterfly_hold.txt butterfly_read.txt
ngspice -b write_trip.spice
python3 ../scripts/sizing_sweep.py
ngspice -b cell_tran.spice

cd ../layout
magic-etri -dnull -noconsole <<'EOF'
source sram6t.tcl
source array.tcl
quit -noprompt
EOF
etri-drc sram_array
xschem-etri --tcl "set top_is_subckt 1" -n -s -q -x -o ../netlist ../sch/sram6t.sch
etri-lvs sram6t ../netlist/sram6t.spice
etri-lvs sram_array ../sim/sram_array.spice
etri-pex sram_array
etri-gds sram_array && etri-drc-klayout sram_array.gds
cd ../sim && ngspice -b array_tran.spice
```

## 2부: sram64x4

1부 셀 256개로 64 words × 4 bits 매크로(행 디코더, 프리차지, 4:1 열 먹스, 센스 앰프, 쓰기 드라이버, 킷 표준셀 제어 블록)를 만들고, 킷의 28핀 패드 프레임에 넣어서 칩 GDS까지 감.
1부 파일은 고치지 않았고 2부에서 새로 만든 건 전부 `sram64x4/` 아래에 있음. 사용법, 결과, 핀 배치는 [sram64x4/README.md](sram64x4/README.md) 참고.

```bash
bash sram64x4/scripts/setup-kit-extra.sh     # 킷의 표준셀(digital_ETRI), 패드(pads_ETRI) 폴더 추가
```
