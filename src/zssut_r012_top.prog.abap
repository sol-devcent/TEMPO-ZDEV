*&---------------------------------------------------------------------*
*&  Include           ZSSUT_I010_TOP
*&---------------------------------------------------------------------*

TABLES: sscrfields,
        knvp,
        tvkot,
        tvkbt,
        zfbih_sfa,
        pa0001,
        zssutdt021,   " Effective Call Target
        zssutdt022,   " Master of Visitation Matrix
        zssutdt023,   " Daily Call Plan: Number Range
        zssutdt024,   " Daily Call Plan: Reason No Call
        zssutdt025,   " Daily Call Plan: Header
        zssutdt026.   " Daily Call Plan: Items
TYPES:
      BEGIN OF t_p0001,
*        checkbox TYPE c,
        pernr    TYPE p0001-pernr,
        ename    TYPE p0001-ename,
      END OF t_p0001,

     BEGIN OF t_bih ,
        bukrs LIKE zfbih_sfa-bukrs,
        vkbur LIKE zfbih_sfa-vkbur,
        bbeln LIKE zfbih_sfa-bbeln,
        daily_call_num LIKE zfbih_sfa-daily_call_num,
      END OF t_bih.


DATA: BEGIN OF gt_itab OCCURS 0,
        mark  TYPE c,
        counter LIKE zssutdt022-counter,
        kunn2 TYPE gpanr,
        kunnr TYPE zssutdt022-kunnr,
        name1 TYPE kna1-name1,
        addrs TYPE char50,
        master_stat_indi(1),
***** tambahkan indiktor buat tgl matriknya

      END OF gt_itab.
DATA: gs_itab   LIKE LINE OF gt_itab.
DATA: gt_025    TYPE TABLE OF zssutdt025 WITH HEADER LINE,
      gt_026    TYPE TABLE OF zssutdt026 WITH HEADER LINE,
      gt_022    TYPE TABLE OF zssutdt022 WITH HEADER LINE,
      gt_022m   TYPE TABLE OF zssutdt022 WITH HEADER LINE.
DATA: gs_header TYPE zssutst010,
      gt_detail TYPE TABLE OF zssutst011.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'T_CONTROL' ITSELF
CONTROLS: t_control TYPE TABLEVIEW USING SCREEN 0100.

DATA: cols LIKE LINE OF t_control-cols.

*&SPWIZARD: LINES OF TABLECONTROL 'T_CONTROL'
DATA:     g_t_control_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

DATA: gv_first_call TYPE char1 VALUE 'X'.

DATA: p1 TYPE char30,
      p2 TYPE char30,
      p3 TYPE char30,
      p4 TYPE char30.

DATA: gv_error LIKE sy-subrc,
      gv_subrc LIKE sy-subrc.
DATA: tko TYPE char30,
      tkb TYPE char30,
      tpe TYPE char30,
      gv_atx TYPE anstx.

DATA: gv_mode(3) TYPE c,
      gv_changes TYPE char1,
      gv_edit(1) TYPE c VALUE ''.
*      gv_error_validation(1) type c.
DATA: gt_temp1 LIKE gt_itab OCCURS 0 WITH HEADER LINE.
data: gv_message(150), gv_text(10).
DATA: gv_release(1).
data: gv_day type p.
data: gv_day1 type p.
data: gv_day2 type p.
RANGES: r_kunn2   FOR zssutst014-kunn2,
        r_kunnr   FOR zssutst014-kunnr,
        r_name1   FOR zssutst014-name1,
        r_addrs   FOR zssutst014-addrs.
DATA: gt_zssutdt025 TYPE STANDARD TABLE OF zssutdt025 WITH HEADER LINE.
DATA: wa_zssutdt025 TYPE zssutdt025 .

DATA: BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE zssutdt025.
DATA:   bbeln LIKE zfbih_sfa-bbeln,
        ename LIKE pa0001-ename,
      END OF gt_out.

DATA: i_p0001 type t_p0001 occurs 0,
      wa_p0001 type t_p0001.

DATA: i_bih type t_bih occurs 0,
      wa_bih type t_bih.

CONSTANTS: _formname TYPE tdsfname VALUE 'ZSSUT_F006',
           _parvw TYPE parvw VALUE 'ZS',
           _spart TYPE spart VALUE '00',
           _vtweg TYPE vtweg VALUE '10'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:     p_vkorg TYPE vkorg OBLIGATORY,
                p_vkbur TYPE vkbur OBLIGATORY MATCHCODE OBJECT h_tvbur.
PARAMETERS:     p_kunn2 like knvp-kunn2 MODIF ID crt. "OBLIGATORY.
PARAMETERS:     p_pernr TYPE pernr_d MODIF ID crt. "OBLIGATORY.
SELECT-OPTIONS: s_pernr FOR zssutdt025-pernr MODIF ID dsp .
SELECT-OPTIONS  s_datum FOR zssutdt025-str_dcp_dat NO-EXTENSION MODIF ID dta default sy-datum to sy-datum.
SELECT-OPTIONS: s_dcp FOR zssutdt025-daily_call_num MODIF ID bb1." NO INTERVALS NO-EXTENSION.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-004.

PARAMETERS: p_crt RADIOBUTTON GROUP grp2 DEFAULT 'X' USER-COMMAND usr1.
PARAMETERS: p_chg RADIOBUTTON GROUP grp2.
PARAMETERS: p_del RADIOBUTTON GROUP grp2.
PARAMETERS: p_dsp RADIOBUTTON GROUP grp2.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN END OF BLOCK b1.
