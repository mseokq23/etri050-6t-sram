# 2부: sram64x4 매크로 → 28핀 칩

1부에서 만든 6T 셀(`layout/sram6t.tcl`)로 64 words x 4 bits SRAM 매크로를 만들고, 킷의 28핀 패드 프레임에 넣어서 칩 GDS까지 가는 과정.
velog 시리즈 **MyChip 6T SRAM 2부** 의 코드, 로그, 사진이 전부 이 폴더에 있음.

1부랑 섞이지 않게 2부에서 만든 건 전부 `sram64x4/` 아래에 있고, 1부 파일은 고치지 않고 그대로 가져다 씀 (셀 레이아웃 스크립트, `sim/sram6t_cell.spice`, `scripts/snm.py`).

| 결과 | 값 |
|---|---|
| 구성 | 16 x 16 셀 어레이 (1부 셀 256개), 4:1 열 먹스, 행 디코더 16, 센스 앰프 + 쓰기 드라이버 4, 제어 블록 (킷 표준셀) |
| 매크로 크기 | 377 x 605 µm (1256 x 2015 λ), 트랜지스터 2380개 |
| 동작 | CLK ↑ 에서 A / WE / DIN 저장, CLK = 1 동안 읽기 / 쓰기, CLK ↓ 에서 DOUT 저장 + 프리차지 |
| 회로도 시뮬 (T = 50 ns, 1부 모델) | 64 words 쓰고 읽기 64/64 일치, CLK↑ → WL 4.67 ns, CLK↑ → SAE 6.20 ns, CLK↓ → DOUT 1.46 ns |
| 레이아웃 추출 시뮬 (16 words) | 16/16 일치, CLK↑ → WL 5.55 ns, CLK↑ → SAE 7.32 ns, CLK↓ → DOUT 1.71 ns |
| 코너 (TT / SS / FF / SF / FS 5 V, SS 4.5 V, FF 5.5 V) | 전부 16/16 일치 |
| 셀 코너 | read SNM 최소 0.578 V (FS), write trip 최소 1.739 V (SS 4.5 V) |
| 블록 / 매크로 | Magic DRC 0, LVS 일치 (행 디코더, 열 회로, 센스 앰프, 제어 블록, 매크로), KLayout 공식 덱 DRC 0 |
| 칩 | 28핀 패드 프레임, 코어 DRC 0, 배선 DRC 0, via 적층 없음, 배선 LVS 일치 |
| 칩 KLayout DRC | 마커 68개 = 패드 프레임만 돌렸을 때와 같은 것 (전부 패드 셀 안), 나머지 0 |

## 킷 폴더 추가

1부의 `scripts/setup-etri050.sh`는 킷에서 tech, spice, scripts만 받음. 2부는 표준셀(digital_ETRI)이랑 패드(pads_ETRI)가 더 필요해서 아래를 한 번 실행하면 됨.
받은 킷은 1부와 같이 `.pdk/`(git-ignored)에 들어가고, 이 레포에는 킷 파일을 넣지 않았음. 패드 프레임, 표준셀은 스크립트가 실행할 때 킷에서 읽어감.

```bash
bash sram64x4/scripts/setup-kit-extra.sh
```

새 터미널을 열면 `sram-run`, `sram-drc`, `sram-gds`, `$ETRI050_PADS` 등이 잡힘.

## 폴더

```
sram64x4/
  rtl/       제어 블록 게이트 수준 Verilog (킷 표준셀)
  sim/       주변 회로 넷리스트 (periph.spice), 블록별 테스트벤치, 코너 덱
  scripts/   넷리스트 / 테스트벤치 생성, 결과 확인, 코너, 기생 추출 시뮬, 단축 명령 (env.sh)
  pnr/       제어 블록 배치배선 (OpenROAD)
  layout/    Magic 명령 스크립트 (블록별 .tcl, LVS 래퍼, LVS 기준 넷리스트 만들기)
  chip/      패드 프레임 + 코어 + 배선 → 칩 GDS, 칩 검사
  docs/      포스트 그림 (docs/img/<포스트 번호>/), 그림 만드는 스크립트
  logs/      실행 로그
  work/      스크립트가 만드는 임시 파일 (git-ignored)
```

## 단축 명령 (scripts/env.sh)

| 명령 | 하는 일 |
|---|---|
| `sram-run <script.tcl>` | 레이아웃 스크립트를 Magic(화면 없이)으로 실행, 문제 있으면 그 줄만 보여줌 |
| `sram-drc <cell>` | 평탄화한 복사본으로 Magic DRC (표준셀 겹침 경고 없이) |
| `sram-lvs <cell> <ref.spice> [subckt]` | 1부 `etri-lvs`와 같음 |
| `sram-gds <cell>` | 평탄화해서 ETRI 스타일 GDS |

## 한 번에 다시 돌리기

```bash
# 회로 (sram64x4/sim)
cd sram64x4/sim
bash ../scripts/ctrl_spice.sh
python3 ../scripts/gen_macro_spice.py -o sram64x4.spice
python3 ../scripts/gen_tb.py --probe -o macro_tb.spice
ngspice -b macro_tb.spice > /dev/null 2>&1            # 약 23분
python3 ../scripts/check_tb.py macro_tb_out.txt
python3 ../scripts/timing.py macro_tb_out.txt
bash ../scripts/corner_iv.sh
python3 ../scripts/cell_corners.py
bash ../scripts/run_macro_corners.sh                   # 약 40분

# 레이아웃 (sram64x4/pnr, sram64x4/layout)
cd ../pnr && bash run_pnr.sh
cd ../layout
for s in array16 rowdrv rowdec colmux colperi sabit sabank ctrl macro; do sram-run $s.tcl; done
sram-drc sram64x4 | grep SRAM-DRC
bash lvs_ref.sh && sram-lvs sram64x4 sram64x4_ref.spice
sram-gds sram64x4 | tail -1 && etri-drc-klayout sram64x4.gds
cd ../sim && bash ../scripts/run_pex.sh                 # 약 7분

# 칩 (레포 폴더에서)
cd ../..
bash sram64x4/chip/run_chip.sh
bash sram64x4/chip/check_chip.sh
```

## 핀 배치 (28핀 패키지)

전원 패드 자리는 킷의 `MPW_PAD_28Pin_IO_Games.mag`와 같게 둠 (1, 8번 VDD / 14, 21번 GND). 패키지 핀 번호는 그 템플릿 기준이고, 실제 본딩은 마이칩(내 칩 제작 서비스) 안내를 확인해야 함.

| 핀 | 신호 | 핀 | 신호 | 핀 | 신호 | 핀 | 신호 |
|---|---|---|---|---|---|---|---|
| 1 | VDD | 8 | VDD | 15 | DIN[3] | 22 | - |
| 2 | A[0] | 9 | WE | 16 | DOUT[0] | 23 | - |
| 3 | A[1] | 10 | CLK | 17 | DOUT[1] | 24 | - |
| 4 | A[2] | 11 | DIN[0] | 18 | DOUT[2] | 25 | - |
| 5 | A[3] | 12 | DIN[1] | 19 | DOUT[3] | 26 | - |
| 6 | A[4] | 13 | DIN[2] | 20 | - | 27 | - |
| 7 | A[5] | 14 | GND | 21 | GND | 28 | - |

`-` 는 연결 안 된 입력 패드(PIC). 보드에서 GND에 묶어두면 됨.
