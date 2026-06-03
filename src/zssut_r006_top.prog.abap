*&---------------------------------------------------------------------*
*&  Include           ZSSUT_R006_TOP
*&---------------------------------------------------------------------*

*&SPWIZARD: DECLARATION OF TABLECONTROL 'T_CONTROL' ITSELF
CONTROLS: t_control TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'T_CONTROL'
DATA:     g_t_control_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

TABLES: zssutdt025.

DATA: BEGIN OF gt_data OCCURS 0,
        vrtnr TYPE vrtnr,
        vkorg TYPE vkorg,
        sdate TYPE sdate.
        INCLUDE STRUCTURE zssutdt026.
DATA: END OF gt_data.
DATA: BEGIN OF gt_itab OCCURS 0,
        vrtnr TYPE vrtnr,
        cname TYPE cname,
        ansvh TYPE ansvh,
        atx   TYPE anstx,
        kunn2 TYPE kunn2,
        jml_bil TYPE int4,
        jml_kerja TYPE int4,
        jml_eff_call TYPE p DECIMALS 2,
        jml_unvisit TYPE int4,
        jml_no_call TYPE int4,
        act_call_up TYPE int4,
        wo_order TYPE int4,
        w_order TYPE int4,
        call_up TYPE int4,
      END OF gt_itab.
DATA: gt_025 TYPE TABLE OF zssutdt025 WITH HEADER LINE,
      gt_026 TYPE TABLE OF zssutdt026 WITH HEADER LINE,
      gs_itab LIKE LINE OF gt_itab.
DATA: p_uname LIKE sy-uname.
DATA: p_udate LIKE sy-datum.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_date FOR zssutdt025-sdate OBLIGATORY DEFAULT sy-datum. " date
PARAMETERS:     p_vkorg TYPE vkorg MODIF ID m1 DEFAULT '8070' OBLIGATORY,  " sales org
                p_vkbur TYPE vkbur MODIF ID m1 DEFAULT '0710' OBLIGATORY.                 " sales office
SELECT-OPTIONS: s_vrtnr FOR zssutdt025-pernr.
SELECTION-SCREEN END OF BLOCK b1.
