*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0029TOP                                           *
*----------------------------------------------------------------------*

CONSTANTS :
  c_hkont    LIKE bseg-hkont VALUE '2140329000',
*  c_objrange LIKE zGDTXdt0011-objrange VALUE 'ZGDTXPPN',
  c_objrange LIKE zgdtxdt0011-objrange VALUE 'ZGDTXPP2',
* ---
  c_objraret LIKE zgdtxdt0011-objrange VALUE 'ZGDTXRTR'.

* addedd by pendi on 9/6/2003
DATA  d_cabtxt LIKE zgdtxdt0101-bdesc.
DATA  d_fakgr LIKE zgdtxdt0103-satgr.

begin_of_block blokz TEXT-100.
begin_of_block blok1 TEXT-001.
PARAMETERS: p_bukrs  LIKE bsis-bukrs OBLIGATORY MEMORY ID buk,
*          p_gsber LIKE bsis-gsber OBLIGATORY MEMORY ID gsb,
            p_brnch  LIKE zgdtxdt0101-brnch OBLIGATORY MEMORY ID gsb,
***added by Rahmadi
            p_busln  LIKE zgdtxdt0102-busln DEFAULT '99'
                    NO-DISPLAY,
            p_tax(5) TYPE p DECIMALS 2 DEFAULT '10'
                     NO-DISPLAY,
***end of addition

***changed for Tempo
            p_masatx LIKE zgdtxdt0003-masatx
*                     OBLIGATORY.
                     NO-DISPLAY.
* transport DEVK927362
*            p_sedh AS CHECKBOX.   "ticked when processing FP Sederhana
***end of Tempo changes
end_of_block blok1.

begin_of_block blok2 TEXT-002.
***changed for Tempo
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(29) text-008.
PARAMETERS: p_mspjk LIKE sy-datum
*                    OBLIGATORY
                    DEFAULT sy-datum
                    NO-DISPLAY.

*SELECTION-SCREEN POSITION 43.
PARAMETER p_excld AS CHECKBOX DEFAULT 'X'.
*SELECTION-SCREEN COMMENT 45(15) text-009 FOR FIELD p_excld.
*SELECTION-SCREEN END OF LINE.
***end of Tempo changes

SELECT-OPTIONS s_belnr FOR bseg-belnr.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT (29) TEXT-003 FOR FIELD p_monat.
PARAMETERS p_monat LIKE bkpf-monat.
*    selection-screen position 50.
PARAMETERS p_gjahr LIKE bseg-gjahr.
SELECTION-SCREEN END OF LINE.

*commented out by pendi on 11/6/2003
*it will be read from zGDTXdt0104
*    PARAMETERS p_blart LIKE bkpf-blart DEFAULT 'DR' OBLIGATORY.
*    PARAMETERS p_hkont LIKE bseg-hkont OBLIGATORY DEFAULT c_hkont.
end_of_block blok2.
end_of_block blokz.

TABLES:
  t001,
  lfa1,
  tgsbt.

**added by Rahmadi
RANGES: r_hkont FOR zgdtxdt0104-hkont,
        r_blart FOR zgdtxdt0104-blart.
**end of addition

***added for Tempo
RANGES: r_hkont_mt FOR zgdtxdt0104-hkont,
        r_blart_mt FOR zgdtxdt0104-blart.
DATA d_tnt_bukrs LIKE t001-bukrs VALUE '8160'.
***end of Tempo addition

DATA: BEGIN OF t_data OCCURS 0.
        INCLUDE STRUCTURE zgdtxdt0002.
        DATA: fakturno1 LIKE zgdtxst0013-fakturno1,
        nocoretax LIKE zgdtxdt0003-nocoretax.
DATA: asset(1).
DATA: "Include structure zGDTXdt0003
  batal       LIKE zgdtxdt0003-batal,
  returcount  LIKE zgdtxdt0003-returcount,
  fakdat      LIKE zgdtxdt0003-fakdat,
  faktur_type LIKE zgdtxdt0003-faktur_type,
  fakppn      LIKE zgdtxdt0003-fakppn,
***added for Tempo
  fakdpp      LIKE zgdtxdt0003-fakdpp,
  fakcurr     LIKE zgdtxdt0003-fakcurr,
***end of Tempo addition
  fakxppnbm   LIKE zgdtxdt0003-fakxppnbm,
  fakppnbm    LIKE zgdtxdt0003-fakppnbm,
*        addrs1 LIKE zgdtxdt0003-addrs1,
*        addrs2 LIKE zgdtxdt0003-addrs2,
*        city LIKE zgdtxdt0003-city,
*        postal LIKE zgdtxdt0003-postal,
****removed for Tempo
*        npwp LIKE zgdtxdt0003-npwp,
****end of Tempo removal
  sspdat      LIKE zgdtxdt0003-sspdat,
  sspval      LIKE zgdtxdt0003-sspval,
  pkpstat     LIKE zgdtxdt0003-pkpstat,
  cetakke     LIKE zgdtxdt0003-cetakke,
  waerk       LIKE zgdtxdt0003-waerk,

*        dpp1 TYPE p DECIMALS 0,
*        ppn1 TYPE p DECIMALS 0,
*        itamt1 TYPE p DECIMALS 0,
  dpp1        LIKE zgdtxdt0002-dpp,
  ppn1        LIKE zgdtxdt0002-ppn,
  itamt1      LIKE zgdtxdt0002-itamt,
  hwbas       LIKE bseg-hwbas,

  check,                           "Check Box utk ALV.
  icon,
*        1 = Red    : Data From Table Tax
*        2 = Green  : Data From SAP Transaction
*        3 = Yellow : Wrong Record Entry

  f,                               "Normal / Retur VAT.
  table,                           "T = Table data S = SAP Data
  msgid(2),                        "Message ID
*        0 = Error
*        1 = Warning
*        9 = Success.

  msgv1(100).                      "Error Message
DATA:  END OF t_data.

*--added by pendi on 11/6/2003
DATA: BEGIN OF t_zgdtxdt0104 OCCURS 0,
        hkont LIKE zgdtxdt0104-hkont,
        blart LIKE zgdtxdt0104-blart,
      END OF t_zgdtxdt0104.

DATA d_answer.
DATA d_save.
DATA d_lock LIKE sy-repid.

DATA dl_fpone LIKE d_fpone.
DATA dl_fptwo LIKE d_fptwo.
DATA dl_objrange LIKE zgdtxdt0005-objrange.
DATA dl_coretax LIKE zgdtxdt0005-coretax.


DATA: va_asset(1).

DEFINE m_m.
  MOVE &1 TO t_data-&2.
END-OF-DEFINITION.


DEFINE m_s.
  CLEAR &1.
  &1-sign = 'I'.
  &1-option = 'EQ'.
  &1-low = &2.
  COLLECT &1.
END-OF-DEFINITION.
