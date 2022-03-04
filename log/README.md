
## 2/28
開発環境の構築

自作OSの開発に利用した環境
- ThinkCentre M720s Small
- Ubuntu 20.04 Focal Fossa

動作確認は、仮想マシンのqemuを使用する。
BOOTX64.EFIというファイルにバイナリを打ち込んで、起動する。gitに完成済みのEFIファイルがあるが、初めての作業なのでoctetaで一つずつ１６進数を打ち込むことにした。
qemuで「Hello, workd」を表示できた。

![hello-woeld](./img/kos-d1-hello-world.png)

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
![edk-hello](./img/kos-d2-ed-hello.png)

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