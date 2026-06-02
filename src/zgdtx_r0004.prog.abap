*$*$ @description Laporan Faktur Pajak Gabungan
*$*$--------------------------------------------------------------------
REPORT zgdtx_r0004 NO STANDARD PAGE HEADING
                     MESSAGE-ID zab.

*$*$--------------------------------------------------------------------
*$*$                    Global/Declaration Data
*$*$--------------------------------------------------------------------
INCLUDE zgdtxnr0004top.

*$*$--------------------------------------------------------------------
*$*$                    Standard Include
*$*$--------------------------------------------------------------------
* Authorization checking macros
INCLUDE zabp_atz.

INCLUDE zabpxin_hdr.

*$*$--------------------------------------------------------------------
*$*$                    Selection Screen
*$*$--------------------------------------------------------------------
SELECTION-SCREEN : BEGIN OF BLOCK opt1 WITH FRAME TITLE text-001.
PARAMETERS       : p_bukrs LIKE zgdtxdt0003-bukrs MODIF ID glb
                                MEMORY ID buk.
SELECT-OPTIONS   : s_brnch FOR zgdtxdt0003-brnch MODIF ID glb.
PARAMETERS       : p_faktur LIKE zgdtxdt0003-fakturno MODIF ID lam.
SELECT-OPTIONS   : s_faktur FOR  zgdtxdt0003-fakturno MODIF ID gab.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) text-003 FOR FIELD p_masatx MODIF ID lap.
SELECTION-SCREEN POSITION 33.
PARAMETERS p_masatx LIKE zgdtxdt0004-masatx MODIF ID lap
                                              MEMORY ID lap.
SELECTION-SCREEN COMMENT 42(20) text-004 MODIF ID lap.
SELECTION-SCREEN END OF LINE.
* -- MD4
PARAMETERS       : p_varnt LIKE disvariant-variant.
* -- MD4
SELECT-OPTIONS:    s_busln  FOR zgdtxdt0002-busln,
                   s_form   FOR zgdtxdt0003-form
*                   NO-EXTENSION
                   NO INTERVALS.

SELECTION-SCREEN : END OF BLOCK opt1.
SELECTION-SCREEN : BEGIN OF BLOCK opt2 WITH FRAME TITLE text-002.
PARAMETERS       : p_lfpst RADIOBUTTON GROUP aaa
                   USER-COMMAND radiobutton DEFAULT 'X',
                   p_lfpsd RADIOBUTTON GROUP aaa,
                   p_lnrst RADIOBUTTON GROUP aaa,
                   p_lfpgb NO-DISPLAY, "RADIOBUTTON GROUP aaa,
                   p_lfpgg NO-DISPLAY. "RADIOBUTTON GROUP aaa.

PARAMETERS p_espt AS CHECKBOX USER-COMMAND spt.  "added for Tempo for
                                                 "eSPT download

SELECTION-SCREEN : END OF BLOCK opt2.
* -- MD3
SELECTION-SCREEN : BEGIN OF BLOCK opt3 WITH FRAME TITLE text-043.
PARAMETERS       : p_allfp DEFAULT 'X' NO-DISPLAY,
                           "RADIOBUTTON GROUP bbb MODIF ID bbb,
                   p_pstfp NO-DISPLAY,
                           "RADIOBUTTON GROUP bbb MODIF ID bbb,
                   p_cbnfp NO-DISPLAY.
"RADIOBUTTON GROUP bbb MODIF ID bbb.
SELECTION-SCREEN : END OF BLOCK opt3.

PARAMETERS p_down AS CHECKBOX MODIF ID dow.
PARAMETERS p_down11 AS CHECKBOX MODIF ID dow.

RANGES: s_fptwo FOR zgdtxdt0005-fptwo.
* -- MD3
*$*$--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Selection-screen ON VALUE-REQUEST
*&---------------------------------------------------------------------*
* -- MD4
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varnt.
  PERFORM f_alv_variant.
* -- MD4

*&---------------------------------------------------------------------*
*& Selection-screen * PAI
*&---------------------------------------------------------------------*
* -- MD4
AT SELECTION-SCREEN.
*  PERFORM f_pai_alv_variant.
* -- MD4

*$*$--------------------------------------------------------------------
*$*$                    User Defined Include (Form-Routine)
*$*$--------------------------------------------------------------------
  INCLUDE zgdtxnr0004f01.

*$*$--------------------------------------------------------------------
*$*$                    Initialization
*$*$--------------------------------------------------------------------
INITIALIZATION.
  PERFORM f_initialization.

*$*$--------------------------------------------------------------------
*$*$                   At Selection Screen On.....
*$*$--------------------------------------------------------------------
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

AT SELECTION-SCREEN ON p_masatx.
*  if p_lfpgg eq 'X'.
  PERFORM f_entry_p_masatx.
*  endif.

AT SELECTION-SCREEN ON p_faktur.
  PERFORM f_entry_p_faktur.

*$*$--------------------------------------------------------------------
*$*$                   At Selection Screen Output
*$*$--------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_screen_manipulation.
  PERFORM f_screen_download.

*$*$--------------------------------------------------------------------
*$*$                    Start of selection
*$*$--------------------------------------------------------------------
START-OF-SELECTION.
* -- Validate Checking fields - MD3
* -- Company Code
  IF p_lfpgb NE 'X' AND p_bukrs EQ space.
    MESSAGE s000 WITH 'Required entry for Company Code...'.
    EXIT.
* -- Business Area
  ELSEIF p_lfpgb NE 'X' AND s_brnch IS INITIAL.
    MESSAGE s000 WITH 'Required entry for Business Area...'.
    EXIT.
* -- Masa Pajak
  ELSEIF p_lfpgb NE 'X' AND p_masatx EQ '000000'.
    MESSAGE s000 WITH 'Required entry for Masa Pajak Period...'.
    EXIT.
  ENDIF.
* -- Faktur Pajak No
  IF p_faktur EQ space AND p_lfpgb EQ 'X'.
    MESSAGE s000 WITH 'Required entry for Faktur Pajak No...'.
    EXIT.
  ENDIF.
* -- MD3

  PERFORM f_get_data.

*$*$--------------------------------------------------------------------
*$*$                    End of selection
*$*$--------------------------------------------------------------------
END-OF-SELECTION.

  PERFORM f_generate_alv.

  IF NOT p_down IS INITIAL.
    PERFORM f_download.
  ENDIF.

  IF NOT p_down11 IS INITIAL.
    PERFORM f_download11.
  ENDIF.


*$*$--------------------------------------------------------------------
*$*$                    Top of Page
*$*$--------------------------------------------------------------------
TOP-OF-PAGE.
  PERFORM f_header_report.



*Text elements
*-------------
* I002     Reporting Options
* I004     YYYY.MM
* I006     No. Fak Jual
* I008     Type
* I010     Harga Unit
* I012     Optional
* I014     XPPnBM
* I016     PPN
* I018     Others
* I020     Lampiran Faktur Pajak Gabungan
* I023     Kode Cabang
* I025     No. Seri Faktur pajak
* I027     Masa pajak
* I029     Alamat
* I031     No Seri Faktur Pjk
* I033     NPWP
* I034     Laporan Faktur Pajak Standar
* I035     Cabang
* I036     Laporan Faktur Pajak Sederhana
* I037     No Retur
* I038     Tgl Retur
* I039     Tgl FP
* I040     Laporan Nota Retur Standar
* I041     Lampiran Faktur Pajak Gabungan All
* I042     Excld
* I043     NPWP Option



*Selection texts
*---------------
*SP_ALLFP         All Faktur Pajak
*SP_BUKRS         Company code
*SP_CBNFP         Faktur Pajak Branch NPWP
*SP_FAKTUR        No. Seri Faktur Pajak
*SP_LFPGB         Lampiran Faktur Pajak Gabungan
*SP_LFPGG         Lampiran Fak. Pjk. Gbungan All
*SP_LFPSD         Laporan Faktur Pajak Sederhana
*SP_LFPST         Laporan Faktur Pajak Standar
*SP_LNRST         Laporan Nota Retur Standar
*SP_MASATX        Tax Period
*SP_PSTFP         Faktur Pajak Head-office NPWP
*SP_VARNT         ALV Variant
*SS_BRNCH         Branch
*SS_BUSLN         Business Line
*SS_FAKTUR        No. Seri Faktur Pajak
*SS_FORM          Form


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
