*&---------------------------------------------------------------------*
*&  Include           ZMM_ABSTOP
*&---------------------------------------------------------------------*
TABLES : mchb, mara, sscrfields, zgdmmt0001, t134m, t023, t001k, t001, t001w.

CLASS lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF stype_organ,
          werks              LIKE  t001w-werks,
          bwkey              LIKE  t001w-bwkey,
          name1              LIKE  t001w-name1,
          bukrs              LIKE  t001-bukrs,
          waers              LIKE  t001-waers,
        END OF stype_organ,
        stab_organ           TYPE STANDARD TABLE OF
                             stype_organ
                             WITH DEFAULT KEY.

TYPES : BEGIN OF stype_buffer,
          werks              LIKE t001w-werks,
          bukrs              LIKE t001-bukrs,
          subrc              LIKE syst-subrc,
        END OF stype_buffer,
        stab_buffer          TYPE STANDARD TABLE OF
                             stype_buffer
                             WITH DEFAULT KEY.

TYPES : BEGIN OF ty_move,
          mblnr              LIKE mseg-mblnr,
          mjahr              LIKE mseg-mjahr,
          zeile              LIKE mseg-zeile,
          line_id            LIKE mseg-line_id,
          parent_id          LIKE mseg-parent_id,
          bwart              LIKE mseg-bwart,
          matnr              LIKE mseg-matnr,
          werks              LIKE mseg-werks,
          lgort              LIKE mseg-lgort,
          charg              LIKE mseg-charg,
          insmk              LIKE mseg-insmk,
          shkzg              LIKE mseg-shkzg,
          menge              LIKE mseg-menge,
          meins              LIKE mseg-meins,
          smbln              LIKE mseg-smbln,
          smblp              LIKE mseg-smblp,
          budat              LIKE mkpf-budat,
          bktxt              LIKE mkpf-bktxt,
          xblnr              LIKE mkpf-xblnr,
          cpudt              LIKE mkpf-cpudt,
          cputm              LIKE mkpf-cputm,
          flag,
        END OF ty_move.

TYPES : BEGIN OF ty_zaccu,
          docat   TYPE zaccdtd-docno,
          docno   TYPE zaccdtd-docno,
          posnr   TYPE zaccdtd-posnr,
          senum   TYPE zaccdtd-senum,
          matnr   TYPE zaccdtm-matnr,
          charg   TYPE zaccdtm-charg,
          werks   TYPE zaccdtm-werks,
          lgort   TYPE zaccdtm-lgort,
          check,
        END OF ty_zaccu.

DATA : gv_repid              TYPE sy-repid,
       ok_code               TYPE sy-ucomm,
       g_outcont             TYPE REF TO cl_gui_custom_container,
       g_outgrid             TYPE REF TO cl_gui_alv_grid,
       gs_exclude            TYPE ui_functions,
       event_receiver        TYPE REF TO lcl_application,
       selected              VALUE 'X',
       gs_variant            LIKE disvariant,
       gs_layout_alv         TYPE lvc_s_layo,
       gt_sort_grid          TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat           TYPE lvc_t_fcat,
       gs_stable             TYPE lvc_s_stbl,
       gs_toolbar            TYPE stb_button.

DATA : g_t_organ             TYPE stab_organ,
       g_s_organ             TYPE stype_organ.

DATA : g_flag_ok(1),
       g_flag_mess_333(1),
       gr_bwart              TYPE RANGE OF bwart,
       gr_movein             TYPE RANGE OF bwart,
       gr_moveout            TYPE RANGE OF bwart,
       gv_text               TYPE char20,
       gv_ucomm              LIKE sy-ucomm,
       gv_reqno              LIKE zgdmmt0001-req_no,
       gv_bapno              LIKE zgdmmt0001-bap_no,
       gv_xblnr              LIKE mkpf-xblnr,
       pa_555                TYPE xfeld,
       pa_z51                TYPE xfeld,
       gv_lifnr              TYPE lfa1-lifnr,
       gv_name1              TYPE lfa1-name1,
       gv_addr1(100),
       gv_addr2(100),
       gv_addr3(100),
       gv_addr4(100),
       gv_autho              TYPE sy-subrc.

DATA : gt_mchb               TYPE STANDARD TABLE OF mchb INITIAL SIZE 0,
       gt_mara               TYPE STANDARD TABLE OF mara INITIAL SIZE 0,
       gt_makt               TYPE STANDARD TABLE OF makt INITIAL SIZE 0,
       gt_mch1               TYPE STANDARD TABLE OF mch1 INITIAL SIZE 0,
       gt_mbew               TYPE STANDARD TABLE OF mbew INITIAL SIZE 0,
       gt_mseg               TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
       gt_mkpf               TYPE STANDARD TABLE OF mkpf INITIAL SIZE 0,
       gt_zgdmmt0001         TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0 WITH HEADER LINE,
       gt_zgdmmt0002         TYPE STANDARD TABLE OF zgdmmt0002 INITIAL SIZE 0,
       gt_001i               TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0,
       gt_001o               TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0,
       gt_t001l              TYPE STANDARD TABLE OF t001l INITIAL SIZE 0,
       gt_movein             TYPE STANDARD TABLE OF ty_move INITIAL SIZE 0,
       gt_moveout            TYPE STANDARD TABLE OF ty_move INITIAL SIZE 0,
       gt_out                TYPE STANDARD TABLE OF zgdmmst001 INITIAL SIZE 0,
       wa_out                TYPE zgdmmst001,
       gt_save               TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0,
       gt_f4                 TYPE STANDARD TABLE OF zgdmmt0001 INITIAL SIZE 0.

DATA : gt_mean               TYPE TABLE OF mean WITH HEADER LINE.
DATA : gs_header             TYPE zgdmmst001.

DATA : d_ctrl_param     LIKE ssfctrlop,
       d_output_opt     TYPE ssfcompop.

DATA : BEGIN OF gt_error OCCURS 0,
         icon(4),
         mess(100),
       END OF gt_error.

DATA : gv_2100 TYPE flag.

DATA : gt_lfa1 TYPE TABLE OF lfa1 WITH HEADER LINE.

CONSTANTS : gc_2100 TYPE char4 VALUE '2100'.

DATA : gt_002       TYPE STANDARD TABLE OF ztspmmdt002,
       gt_zaccu     TYPE STANDARD TABLE OF ty_zaccu,
       gt_zaccdtm   TYPE STANDARD TABLE OF zaccdtm,
       gs_001       TYPE ztnpqmdt001,
       gv_host      TYPE rfcdisplay-rfchost.

DATA : dynpread     TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

DATA : gv_apo.
