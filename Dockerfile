FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04

ARG USERNAME=vscode


# install development tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    llvm-7-dev \
    lld-7 \
    clang-7 \
    nasm \
    acpica-tools \
    uuid-dev \
    qemu-system-x86 \
    qemu-utils \
    xauth \
    unzip \
    # added
    qemu-system-gui \
    dosfstools \
    git \
    python3-distutils \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists

# set alternatives
RUN for item in \
        llvm-PerfectShuffle \
        llvm-ar \
        llvm-as \
        llvm-bcanalyzer \
        llvm-cat \
        llvm-cfi-verify \
        llvm-config \
        llvm-cov \
        llvm-c-test \
        llvm-cvtres \
        llvm-cxxdump \
        llvm-cxxfilt \
        llvm-diff \
        llvm-dis \
        llvm-dlltool \
        llvm-dwarfdump \
        llvm-dwp \
        llvm-exegesis \
        llvm-extract \
        llvm-lib \
        llvm-link \
        llvm-lto \
        llvm-lto2 \
        llvm-mc \
        llvm-mca \
        llvm-modextract \
        llvm-mt \
        llvm-nm \
        llvm-objcopy \
        llvm-objdump \
        llvm-opt-report \
        llvm-pdbutil \
        llvm-profdata \
        llvm-ranlib \
        llvm-rc \
        llvm-readelf \
        llvm-readobj \
        llvm-rtdyld \
        llvm-size \
        llvm-split \
        llvm-stress \
        llvm-strings \
        llvm-strip \
        llvm-symbolizer \
        llvm-tblgen \
        llvm-undname \
        llvm-xray \
        ld.lld \
        lld-link \
        clang \
        clang++ \
        clang-cpp \
    ; do \
        update-alternatives --install "/usr/bin/${item}" "${item}" "/usr/bin/${item}-7" 50 \
    ; done

# entrypoint shell script
COPY build_kernel_loader.sh "/home/${USERNAME}/build_kernel_loader.sh"
RUN chmod +x "/home/${USERNAME}/build_kernel_loader.sh"


# switch to unprivileged
USER ${USERNAME}
WORKDIR /home/${USERNAME}
SHELL [ "/bin/bash", "-c" ]

# build EDK II
# 38c8be123aced4cc8ad5c7e0da9121a181b94251 is known latest good version
# do not use --depth=1 since some git upstream does not support fetching single commit?
# still dont get it why this only happens on arm64 and not amd64
RUN git clone https://github.com/tianocore/edk2.git && \
    cd edk2 && \
    git fetch --no-recurse-submodules origin 38c8be123aced4cc8ad5c7e0da9121a181b94251 && \
    git checkout FETCH_HEAD && \
    git submodule update --init --recursive && \
    make -C BaseTools/Source/C

# clone mikanos devenv
RUN git clone https://github.com/uchan-nos/mikanos-build.git osbook

# download standard libraries
RUN curl -L https://github.com/uchan-nos/mikanos-build/releases/download/v2.0/x86_64-elf.tar.gz \
  | tar xzvf - -C osbook/devenv


# add ~/osbook/devenv to PATH
ENV PATH="/home/${USERNAME}/osbook/devenv:${PATH}"

# set X11 server address
ENV DISPLAY=host.docker.internal:0


# override startup command, taken from VSCode Devcontainer logs
CMD ["/bin/bash", "-c", "echo Container started ; trap \"exit 0\" 15; while sleep 1 & wait $!; do :; done"]