;-------------	 loader和kernel的配置   ----------
LOADER_BASE_ADDR equ 0x900 ; 从0x500开始也可以
LOADER_START_SECTOR equ 0x2 ;  loader 在硬盘上的逻辑扇区地址, 即 LBA 地址, 是从0开始. 这里选择第3个扇区作为loader