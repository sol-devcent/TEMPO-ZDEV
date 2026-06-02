*$*$ Title      :  Batal Faktur Pajak
*$*$--------------------------------------------------------------------
REPORT zgdtx_e0024 NO STANDARD PAGE HEADING.

*$*$-user defined include-----------------------------------------------
INCLUDE: zgdtxne0024top,
         zstdxin_atz,
         zstdxin_udf,
         zabpxin_hdr.

*$*$--------------------------------------------------------------------
*$*$ Selection Screen
*$*$--------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK abc1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
***modified by Rahmadi
*   p_vkorg    LIKE vbrk-vkorg OBLIGATORY,
*   p_gsber    LIKE vbak-gsber OBLIGATORY,
*   p_spart    LIKE vbrk-spart OBLIGATORY.
  p_bukrs LIKE zgdtxdt0101-bukrs OBLIGATORY,
  p_brnch LIKE zgdtxdt0101-brnch OBLIGATORY,
  p_busln LIKE zgdtxdt0102-busln OBLIGATORY.
***end of modification
SELECTION-SCREEN END OF BLOCK abc1.

SELECTION-SCREEN  BEGIN OF BLOCK abc2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
PARAMETERS  p_sdh RADIOBUTTON GROUP rad1 USER-COMMAND proses.
SELECTION-SCREEN COMMENT 05(25) TEXT-004 FOR FIELD p_sdh.
SELECTION-SCREEN POSITION 30.
PARAMETERS p_vbeln LIKE vbrk-vbeln .
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
PARAMETERS  p_std RADIOBUTTON GROUP rad1.
SELECTION-SCREEN COMMENT 05(25) TEXT-003 FOR FIELD p_std.
SELECTION-SCREEN POSITION 30.
PARAMETERS p_faktur LIKE rf61lbd-abrres19.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
PARAMETERS  p_cor RADIOBUTTON GROUP rad1.
SELECTION-SCREEN COMMENT 05(25) TEXT-005 FOR FIELD p_cor.
SELECTION-SCREEN POSITION 30.
PARAMETERS p_coret LIKE rf61lbd-abrres19.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK abc2.


*$*$-user defined include-----------------------------------------------
INCLUDE zgdtxne0024f01.

*$*$--------------------------------------------------------------------
*$*$ Initialization
*$*$--------------------------------------------------------------------
INITIALIZATION.
  p_sdh = 'X'.

*$*$--------------------------------------------------------------------
*$*$ At Selection Screen
*$*$--------------------------------------------------------------------
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

AT SELECTION-SCREEN .
***added by Rahmadi
*-Check whether Tax period program is still running
  CLEAR d_tx04_lock_subrc.
  PERFORM f_check_tax_period CHANGING d_tx04_lock_subrc.
  IF d_tx04_lock_subrc <> 0.
    STOP.
  ENDIF.
***end of addition

  PERFORM f_selection_screen.

*$*$--------------------------------------------------------------------
*$*$ At Selection Screen Output
*$*$--------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_screen.

*$*$--------------------------------------------------------------------
*$*$ Start of selection
*$*$--------------------------------------------------------------------
START-OF-SELECTION.

  IF p_vbeln NE space OR p_faktur NE space OR p_coret NE space.
    PERFORM f_get_data.
    CHECK d_subrc = 0.
    PERFORM f_write_data.
  ELSE.
    MESSAGE i000(zab) WITH 'Please enter the required info.'
                          'Choose either FP Standard or'
                          'FP sederhana or FP CORETAX.'.
  ENDIF.



*Text elements
*-------------
* I002     Faktur Pajak Type
* I004     Faktur Pajak Sederhana



*Selection texts
*---------------
*SP_BRNCH         Branch
*SP_BUKRS         Company code
*SP_BUSLN         Business line
*SP_FAKTUR        Faktur No.
*SP_SDH           Faktur pajak Sederhana
*SP_STD           Faktur pajak Standard


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
