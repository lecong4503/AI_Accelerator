AI_Accelerator/
├── README.md
├── docs/                  # 프로젝트 설명 및 구조 문서
│   └── architecture.png   # 시스템 구조도, 흐름도 등
├── src/                   # 핵심 소스 코드
│   ├── verilog/           # Verilog / SystemVerilog 소스
│   │   ├── pe/            # Processing Element
│   │   ├── array/         # Systolic Array 등 상위 구조
│   │   └── top/           # Top module
│   ├── hls/               # HLS 코드 (사용하는 경우)
│   └── sw/                # C/Python 테스트 및 드라이버 코드
├── tb/                    # Testbenches
│   ├── verilog_tb/        # Verilog 기반 테스트벤치
│   └── python_tb/         # 시뮬레이션용 Python 테스트 (예: cocotb 등)
├── data/                  # 테스트 이미지, weight, 입력 데이터
│   ├── images/            # 실험용 이미지
│   └── weights/           # 학습된 Weight 파일 (INT8 등)
├── script/                # 자동화 스크립트 (run.py, build.sh 등)
├── result/                # 시뮬레이션/합성 결과 저장
│   ├── waveform/          # 파형 데이터 (VCD, FSDB)
│   └── power_rpt/         # 전력, 리소스 보고서
├── vivado/                # Vivado 프로젝트 및 IP
├── notebook/              # 실험 결과 분석용 Jupyter 노트북
├── report/                # 논문 초안, 발표자료 등
│   └── thesis_draft.pdf
└── .gitignore             # 빌드파일, 시뮬레이션 로그 등 무시 설정
