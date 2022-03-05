
## 2/28
開発環境の構築

自作OSの開発に利用した環境
- ThinkCentre M720s Small
- Ubuntu 20.04 Focal Fossa

動作確認は、仮想マシンのqemuを使用する。
BOOTX64.EFIというファイルにバイナリを打ち込んで、起動する。gitに完成済みのEFIファイルがあるが、初めての作業なのでoctetaで一つずつ１６進数を打ち込むことにした。
qemuで「Hello, workd」を表示できた。

![hello-woeld](../img/kos-d1-hello-world.png)

C言語で同じ動作をするEFIファイルを作成する。
Cプログラム→（コンパイラ clang）→オブジェクトファイル→ (リンカ lld-link) → EFIファイル(hello.efi)

## 3/1
EDKⅡを利用してアプリケーション開発ができるようにする。
まずはEDKでのハローワールドから始める。

EDKⅡ：UEFI BIOS上で動作するアプリケーション開発キット

２章を読んだのみで実装は進まなかった。

## 3/4

EDKでハローワールド
KosLoaderPkg/以下にLoad.inf, Main.c, KosLoaderPkg.dec, KosLoaderPkg.decの４ファイルを作成し、EDKを用いてビルドを行う
→Loader.efiが生成されるため、これをBOOTX64.EFIとして保存する。(run_qemu.shで実行できる)

実行結果：edkでハローワールド(めっちゃ誤字している)
![edk-hello](../img/kos-d2-edk-hello.png)

今後このアプリケーションをブートローダとして拡張していく

まずはメモリマップの取得を行う。

edkで用意されている機能`gBS->GetMemoryMap`を使用する。
```c
EFI_STATUS GetMemoryMap(
    IN OUT UINTN *MemoryMapSize,
    IN OUT EFI_MEMORY_DSCRIPTOR *Memorymap,
    OUT UINTN *MapKey,
    OUT UINTN *DescriptorSize,
    OUT UINT32 *DescriptorVersion
);
```
- MemoryMapSize：MemoryMapのバッファサイズ（出力は実際のメモリサイズ）
- MemoryMap: メモリマップ書き込み先のメモリ領域の先頭ポインタ
- MapKey：メモリマップを識別するための値を書き込む変数を指定する
- DescriptorSize: メモリマップの個々の行を表すメモリディスクリプタのバイト数
- DescriptorVersion: メモリディスクリプタ構造体のバージョン番号（使用しない）


メモリマップの読み込み成功。下図はメモリディスクリプタの各要素csvファイルとして出力している。[memorymap](./memorymap)
```
Index, Type, Type(name), PhysicalStart, NumberOfPages, Attribute
0, 3, EfiBootServicesCode, 00000000, 1, F
1, 7, EfiConventionalMemory, 00001000, 9F, F
2, 7, EfiConventionalMemory, 00100000, 700, F
3, A, EfiACPIMemoryNVS, 00800000, 8, F
4, 7, EfiConventionalMemory, 00808000, 8, F
5, A, EfiACPIMemoryNVS, 00810000, F0, F
6, 4, EfiBootServicesData, 00900000, B00, F
7, 7, EfiConventionalMemory, 01400000, 3AB36, F
...
```

第二章おわり！

## 3/5
第３章レジスタ

QEMUモニタの使い方(GDBと同じか？) [wikibooks](https://en.wikibooks.org/wiki/QEMU/Monitor)
- info registers
- x/2i 0x067ae4c4


- 初めてのkernel作成
- ブートローダとkernelは別ファイルとして開発する
- カーネルのコンパイル時にエラーが出た
```bash
# kernel/main.cpp のコンパイル
~/kos/kernel$ clang++ -O2 -Wall --target=X86_64-elf -ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -std=c++17 -c main.cpp
clang: warning: argument unused during compilation: '-mno-red-zone' [-Wunused-command-line-argument]
error: unknown target triple 'X86_64---elf', please use -triple or -arch
```

- `--target`フラグなしでコンパイルを実行して解決
- コンパイラがmain.oを生成する
- 次にリンカを実行して、main.oから実行可能ファイル(elf)を作成する
```bash
~/kos/kernel$ ld.lld --entry KernelMain -z norelro --image-base 0x100000 --static -o kernel.elf main.o
```

```
main.cpp -> (clang++でコンパイル) -> main.o -> (ld.lldでリンク) -> kernel.elf
```

- 次に、ブートローダを拡張してカーネルファイルを読み込む機能を追加する
- 謎のオフセット24バイト（下記コード）
- → ELFの仕様で、64bit用のEFLのエントリポイントアドレスは、オフセット24バイトの位置から8バイト整数で書かれている。
```c
   // Boot kernel
    UINT64 entry_addr = *(UINT64*)(kernel_base_addr + 24);

    typedef void EntryPointType(void);
    EntryPointType* entry_point = (EntryPointType*)entry_addr;
    entry_point();
```

- kernelのロード＋起動成功
![kernel-load](../img/kos-day03-kernel.png)


- 画面の色をいじっていく
- まずはブートローダでピクセルを描く(UEFIのGOP機能)
- openProtocol関数でgopを取得する
```c
gBS->OpenProtocol(
        gop_handles[0],
        &gEfiGraphicsOutputProtocolGuid,
        (VOID**)gop,
        image_handle,
        NULL,
        EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
    );
```

UEFIでピクセル色指定をした結果
![uefi color](../img//kos-day03-uefi-color.png)

- 次にカーネルでピクセルを描く+エラー処理
- gBSの各関数の戻り値(EFI_STATUS型)をチェックしてエラーの場合には、メッセージ表示＋hltを行う。

![kernel color](../img/kos-day03-uefi-color.png)