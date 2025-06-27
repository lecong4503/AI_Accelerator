## 📁 프로젝트 디렉토리 구조

AI_Accelerator/
├── README.md # 프로젝트 설명 파일
├── docs/ # 구조도, 설계 문서
│ └── architecture.png # 시스템 구조도
├── src/ # 핵심 소스 코드
│ ├── verilog/ # Verilog / SystemVerilog 모듈
│ │ ├── pe/ # PE (Processing Element) 모듈
│ │ ├── array/ # Systolic Array 등 상위 구조
│ │ └── top/ # Top-level 모듈
│ ├── hls/ # HLS (High-Level Synthesis) 코드
│ └── sw/ # 소프트웨어 드라이버 및 테스트 코드
├── tb/ # 테스트벤치
│ ├── verilog_tb/ # Verilog 기반 테스트
│ └── python_tb/ # Python 시뮬레이션 (예: cocotb)
├── data/ # 실험용 데이터 (이미지, weight 등)
│ ├── images/ # 테스트 이미지
│ └── weights/ # INT8 weight 파일
├── script/ # 자동 실행/빌드 스크립트
├── result/ # 결과 저장 디렉토리
│ ├── waveform/ # 시뮬레이션 파형 (vcd 등)
│ └── power_rpt/ # 전력, LUT 등 리포트
├── vivado/ # Vivado 프로젝트 파일
├── notebook/ # Jupyter 노트북 (실험 분석)
├── report/ # 논문 초안 및 발표 자료
│ └── thesis_draft.pdf
└── .gitignore # Git 무시 설정 파일
