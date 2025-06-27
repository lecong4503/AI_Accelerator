```text
AI_Accelerator/
├── README.md                 # 프로젝트 설명
├── docs/                     # 구조도·설계 문서
│   └── architecture.png      # 시스템 구조도
├── src/                      # 핵심 소스 코드
│   ├── verilog/              # Verilog / SystemVerilog
│   │   ├── pe/               # Processing Element 모듈
│   │   ├── array/            # Systolic Array 등 상위 구조
│   │   └── top/              # Top-level 모듈
│   ├── hls/                  # HLS 코드
│   └── sw/                   # 드라이버·테스트 SW
├── tb/                       # 테스트벤치
│   ├── verilog_tb/           # Verilog 테스트
│   └── python_tb/            # cocotb 등 Python 시뮬
├── data/                     # 실험 데이터
│   ├── images/               # 테스트 이미지
│   └── weights/              # INT8 weight 파일
├── script/                   # 빌드·자동화 스크립트
├── result/                   # 결과
│   ├── waveform/             # 시뮬레이션 파형(VCD 등)
│   └── power_rpt/            # 전력·LUT 리포트
├── vivado/                   # Vivado 프로젝트
├── notebook/                 # Jupyter 노트북
├── report/                   # 논문·발표 자료
│   └── thesis_draft.pdf
└── .gitignore                # Git 무시 설정
