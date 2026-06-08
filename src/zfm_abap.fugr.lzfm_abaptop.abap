FUNCTION-POOL zfm_abap      MESSAGE-ID   c$.

TYPE-POOLS: sabc,
            espap.

INCLUDE cbui09.    "type boolean and constant values TRUE and FALSE

CONSTANTS: lc_fileformat_binary        LIKE rlgrap-filetype
                                       VALUE 'BIN'.
