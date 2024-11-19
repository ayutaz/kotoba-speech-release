# ベースイメージを指定
FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

# 環境変数の設定
ENV HOST=docker \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=America/Los_Angeles \
    CUDA_HOME=/usr/local/cuda

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 必要なシステムパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        curl \
        ca-certificates \
        sudo \
        less \
        htop \
        git \
        tzdata \
        wget \
        tmux \
        zip \
        unzip \
        zsh \
        stow \
        subversion \
        fasd \
        ninja-build \
        python3-dev \
        libsndfile1 \
        ffmpeg \
        gfortran \
        && rm -rf /var/lib/apt/lists/*

# HOMEと作業ディレクトリの設定
ENV HOME=/home/user
WORKDIR /home/user/kotoba_speech_release

# pipのキャッシュを無効化
ENV PIP_NO_CACHE_DIR=1

# pip, setuptools, wheelをアップグレード
RUN pip install --upgrade pip setuptools wheel

# numpyを特定のバージョンでインストール
RUN pip install numpy==1.26.4

# requirements.txtをコピー（仮の場所にコピー）
COPY requirements.txt /tmp/requirements.txt

# requirements.txtからPythonパッケージをインストール
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# xformersをインストール
RUN pip install xformers==0.0.24

# audiocraftをクローンして特定のコミットハッシュでインストール
RUN git clone https://github.com/facebookresearch/audiocraft.git \
    && cd audiocraft \
    && git checkout f5931855b8e662462d0af8256d9c084ca04d6a94 \
    && pip install . \
    && cd .. \
    && rm -rf audiocraft

# FlashAttentionのホイールをダウンロードしてインストール
RUN wget -q https://github.com/Dao-AILab/flash-attention/releases/download/v2.7.0.post2/flash_attn-2.7.0.post2%2Bcu12torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl \
    && pip install flash_attn-2.7.0.post2+cu12torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl \
    && rm flash_attn-2.7.0.post2+cu12torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl

# torchaudioのインストール（バージョン指定）
RUN pip install torchaudio==2.2.0+cu121 --extra-index-url https://download.pytorch.org/whl/cu121
