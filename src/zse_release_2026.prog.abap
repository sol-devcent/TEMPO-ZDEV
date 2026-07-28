REPORT zse_release MESSAGE-ID zs NO STANDARD PAGE HEADING
*                              line-count 60
                                  LINE-SIZE  305.
************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  :                                                        *
* Created on  :                                                        *
* Version     : 0.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: vbak, vbuk,
        knkk,
        tvkbz,
        usgrp_user,
        zsauth,
        zscl_class,
        zscl_top,
        vbkred,
        zsbankgrs,
        zghsd_tabcli2016,
        zghsd_tabcli2017,
        zscl_backtoback,
        zsgrpbank, zscl_trading,
        zscl_kredit, zsmapping_soff, zscl_kredit_sut,
        zsl_hsales,
        knvv.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_key,
          vbeln LIKE vbuk-vbeln,
        END OF t_key.
TYPES: BEGIN OF t_zghsd_tabcli.
         INCLUDE STRUCTURE zghsd_tabcli2016. "zghsd_tabcli.
         TYPES :  flagcl(1),
         flagtop(1),
         authcl(1),
         authtop(1),
         flag(1),
         flag1(1),
         flag2(1),
         flag3(1),
       END OF t_zghsd_tabcli,
       BEGIN OF t_itab,
         auart           LIKE vbak-auart,
         vkorg           LIKE vbak-vkorg,
         vtweg           LIKE vbak-vtweg,
         vkbur           LIKE vbak-vkbur,
         knkli           LIKE vbak-knkli,
         kkber           LIKE vbak-kkber,
         kunnr           LIKE vbak-kunnr,
         vbeln           LIKE vbak-vbeln,
         erdat           LIKE vbak-erdat,
         erzet           LIKE vbak-erzet,
         netwr           LIKE vbak-netwr,
         audat           LIKE vbak-audat,
         kvgr3           LIKE vbak-kvgr3,
         kvgr4           LIKE vbak-kvgr4,
         abrvw           LIKE vbak-abrvw,
         name1           LIKE kna1-name1,
         brsch           LIKE kna1-brsch,
         zterm           LIKE knb1-zterm,
         altkn           LIKE knb1-altkn,
         cl_awal         LIKE knkk-dbekr,
         cl_current      TYPE wertv10,
         cl_hitung       TYPE wertv10,
         credit_exposure LIKE knkk-klimk,
         ar              LIKE knkk-klimk,
         credit_value    LIKE knkk-klimk,
         over_credit     LIKE knkk-klimk,
         remark          LIKE usgrp_user-usergroup,
         remark1         LIKE usgrp_user-usergroup,
         remark2         LIKE usgrp_user-usergroup,
         remark3         LIKE usgrp_user-usergroup,
         remark_top      LIKE usgrp_user-usergroup,
         remark_top1     LIKE usgrp_user-usergroup,
         remark_top2     LIKE usgrp_user-usergroup,
         remark_top3     LIKE usgrp_user-usergroup,
         remark_cl       LIKE usgrp_user-usergroup,
         remark_cl1      LIKE usgrp_user-usergroup,
         remark_cl2      LIKE usgrp_user-usergroup,
         remark_cl3      LIKE usgrp_user-usergroup,
         status(15),
         top             LIKE zscl_top-zhari,
         top_hitung(5),
         dso             LIKE zscl_top-zhari,
         dso_hitung(5),
         persen          LIKE knkk-dbekr,
         flagtop(1),
         flagcl(1),
         authtop(1),
         authcl(1),
         mark1(1),
         mark2(1),
         zbd1t           LIKE bsid-zbd1t,
         flag_top(1),
         reason(25),
         kdgrp           LIKE knvv-kdgrp,
         blart           LIKE bsid-blart,
         postst(1),
         backtoback(1),
         authback(1),
         zflagcl(1),
         zflagtop(1),
         zstatus(25),
         zflagback(1),
         bnddt           LIKE vbak-bnddt,
         kraus           LIKE knkk-kraus,
         name_kraus(40),
       END OF t_itab,
       BEGIN OF t_form1,
         temp_no TYPE i,
         znou(2),
         vbeln   LIKE vbak-vbeln,
         kunnr   LIKE  vbak-kunnr,
         kvgr3   LIKE vbak-kvgr3,
         name1   LIKE  kna1-name1,
         m0      LIKE  s603-umkzwi1,
         m1      LIKE  s603-umkzwi1,
         m2      LIKE  s603-umkzwi1,
         m3      LIKE  s603-umkzwi1,
         m4      LIKE  s603-umkzwi1,
         m5      LIKE  s603-umkzwi1,
         m6      LIKE  s603-umkzwi1,
         avrm    LIKE  s603-umkzwi1,
         ar0     LIKE  knc1-um01u,
         ar1     LIKE  knc1-um01u,
         ar2     LIKE  knc1-um01u,
         ar3     LIKE  knc1-um01u,
         ar4     LIKE  knc1-um01u,
         ar5     LIKE  knc1-um01u,
         ar6     LIKE  knc1-um01u,
         ar7     LIKE  knc1-um01u,
         ar8     LIKE  knc1-um01u,
         ar9     LIKE  knc1-um01u,
         ar10    LIKE  knc1-um01u,
         ar11    LIKE  knc1-um01u,
         ar12    LIKE  knc1-um01u,
         avrar   LIKE  knc1-um01u,
       END OF t_form1,
       BEGIN OF t_form2,
         temp_no         TYPE i,
         znou(2),
         vbeln           LIKE vbak-vbeln,
         kunnr           LIKE  vbak-kunnr,
         name1           LIKE  kna1-name1,
         kvgr3           LIKE vbak-kvgr3,
         auart           LIKE vbak-auart,
         vkorg           LIKE vbak-vkorg,
         vkbur           LIKE vbak-vkbur,
         knkli           LIKE vbak-knkli,
         kkber           LIKE vbak-kkber,
         netwr           LIKE vbak-netwr,
         zterm           LIKE knb1-zterm,
         cl_awal         LIKE knkk-dbekr,
         cl_current      TYPE wertv10,
         cl_hitung       TYPE wertv10,
         credit_exposure LIKE knkk-klimk,
         ar              LIKE knkk-klimk,
         credit_value    LIKE knkk-klimk,
         over_credit     LIKE knkk-klimk,
         remark          LIKE usgrp_user-usergroup,
         remark_top      LIKE usgrp_user-usergroup,
         remark_cl       LIKE usgrp_user-usergroup,
         remark1         LIKE usgrp_user-usergroup,
         remark2         LIKE usgrp_user-usergroup,
         status(10),
         top             LIKE zscl_top-zhari,
         top_hitung(5),
         persen          LIKE knkk-dbekr,
         flagtop(1),
         flagcl(1),
         authtop(1),
         authcl(1),
         mark1(1),
         mark2(1),
         zbd1t           LIKE bsid-zbd1t,
         flag_top(1),
         reason(25),

       END OF t_form2,

       BEGIN OF t_vbeln,
         vbeln LIKE vbak-vbeln,
       END OF t_vbeln,

       BEGIN OF t_bsid,
         bukrs    LIKE bsid-bukrs,
         kunnr    LIKE bsid-kunnr,
         blart    LIKE bsid-blart,
         belnr    LIKE bsid-belnr,
         zfbdt    LIKE bsid-zfbdt,
         zbd1t    LIKE bsid-zbd1t,
         umskz    LIKE bsid-umskz,
         bstat    LIKE bsid-bstat,
         fkart    LIKE vbrk-fkart,
         zuonr    LIKE bsid-zuonr,
         budat    LIKE bsid-budat,
         top      TYPE p,
         stat1(1),
       END OF t_bsid,

       BEGIN OF t_bsad,
         bukrs LIKE bsid-bukrs,
         kunnr LIKE bsid-kunnr,
         blart LIKE bsid-blart,
         belnr LIKE bsid-belnr,
         zfbdt LIKE bsid-zfbdt,
         zbd1t LIKE bsid-zbd1t,
         umskz LIKE bsid-umskz,
         bstat LIKE bsid-bstat,
         zuonr LIKE bsid-zuonr,
       END OF t_bsad,

       BEGIN OF t_kunnr,
         stat1(1),
         kunnr       LIKE bsid-kunnr,
         fkart       LIKE vbrk-fkart,
         blart       LIKE bsid-blart,
         top(7),
         n_top       TYPE p,
         zbd1t       LIKE bsid-zbd1t,
         l_top(7),
         flag_top(1),
       END OF t_kunnr,
       BEGIN OF t_zscl_kredit.
         INCLUDE STRUCTURE zscl_kredit.
       TYPES:  END OF t_zscl_kredit,
       BEGIN OF t_knc1.
         INCLUDE STRUCTURE knc1.
         TYPES:     skfor           LIKE knkk-skfor,
         kdgrp           LIKE knkk-kdgrp,
         credit_exposure LIKE knkk-klimk,
       END OF t_knc1.
TYPES:   BEGIN OF t_s603,
           spmon   LIKE s603-spmon,
           pkunwe  LIKE s603-pkunwe,
           umkzwi1 LIKE s603-umkzwi1,
           gukzwi1 LIKE s603-gukzwi1,
           waerk   LIKE s603-waerk,
           vkbur   LIKE s603-vkbur,
         END OF t_s603,
         BEGIN OF t_zsbankgrs.
           INCLUDE STRUCTURE zsbankgrs.
         TYPES:  END OF t_zsbankgrs.
TYPES: BEGIN OF t_zscl_top,
         zurut     LIKE zscl_top-zurut,
         usrgroup  LIKE zscl_top-usrgroup,
         blart     LIKE zscl_top-blart,
         kvgr3     LIKE zscl_top-kvgr3,
         kvgr4     LIKE zscl_top-kvgr4,
         zhari     LIKE zscl_top-zhari,
         zhextra   LIKE zscl_top-zhextra,
         zdept     LIKE zscl_top-zdept,
         usrgroup1 LIKE zscl_top-usrgroup,
         usrgroup2 LIKE zscl_top-usrgroup,
       END OF  t_zscl_top.

DATA : p_time         TYPE t, v_message(200).
DATA: gt_zsmapping_soff TYPE zsmapping_soff OCCURS 0,
      gs_zsmapping_soff TYPE zsmapping_soff.
DATA: gt_zscl_trading TYPE zscl_trading OCCURS 0,
      gs_zscl_trading TYPE zscl_trading.
DATA: gs_zproject TYPE zproject.

*----------------------------------------------------------------------*
*       CLASS my DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS my DEFINITION.
  PUBLIC SECTION.
    METHODS : run_handler FOR EVENT finished OF cl_gui_timer.
ENDCLASS.                    "my DEFINITION
DATA timer TYPE REF TO cl_gui_timer.
DATA myh TYPE REF TO my.
*----------------------------------------------------------------------*
*       CLASS my IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS my IMPLEMENTATION.
  METHOD run_handler.
    CALL METHOD timer->run.
    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'REFR'.
  ENDMETHOD.                    "run_handler
ENDCLASS.                    "my IMPLEMENTATION

************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE zsheader.
INCLUDE <%_list>.
************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************
DATA: i_s603             TYPE t_s603 OCCURS 0,
      wa_s603            TYPE t_s603,
      i_knc1             TYPE t_knc1 OCCURS 0,
      wa_knc1            TYPE t_knc1,
      i_form1            TYPE t_form1 OCCURS 0,
      wa_form1           TYPE t_form1,
      i_form2            TYPE t_form2 OCCURS 0,
      wa_form2           TYPE t_form2,
      va_list            TYPE slist_listline,
      i_vbeln            TYPE t_vbeln OCCURS 0,
      i_bsid             TYPE t_bsid OCCURS 0,
      i_bsad             TYPE t_bsad OCCURS 0 WITH HEADER LINE,
      i_kunnr            TYPE t_kunnr OCCURS 0,
      ii_kunnr           TYPE t_kunnr OCCURS 0,
      i_zscl_kredit      TYPE t_zscl_kredit OCCURS 0,
      i_zscl_kredit_user TYPE t_zscl_kredit OCCURS 0,
      i_zsbankgrs        TYPE t_zsbankgrs OCCURS 0,
      i_zsbankgrp        TYPE t_zsbankgrs OCCURS 0,
      i_zscl_top         LIKE zscl_top_sut OCCURS 0 WITH HEADER LINE,
      i_zscl_top_cross   LIKE zscl_top_cross OCCURS 0 WITH HEADER LINE,
      i_zscl_top_sut     LIKE zscl_top_sut OCCURS 0 WITH HEADER LINE,
      i_zscl_top3        TYPE t_zscl_top OCCURS 0,
      i_zscl_top4        TYPE t_zscl_top OCCURS 0,
      i_zscl_top_user    TYPE t_zscl_top OCCURS 0,
      wa_zscl_top        TYPE t_zscl_top,
      wa_zscl_top_sut    TYPE zscl_top_sut,
      wa_zsbankgrs       TYPE t_zsbankgrs,
      wa_zscl_kredit     TYPE t_zscl_kredit,
      wa_kunnr           TYPE t_kunnr,
      wa_bsid            TYPE t_bsid,
      wa_vbeln           TYPE t_vbeln,
      wa_itab            TYPE t_itab,
      wa_itab2           TYPE t_itab,
      i_itab1            TYPE t_itab OCCURS 0,
      i_itab             TYPE t_itab OCCURS 0,
      i_itab2            TYPE t_itab OCCURS 0,
      i_itab3            TYPE t_itab OCCURS 0,
      i_key              TYPE t_key OCCURS 0,
      wa_key             TYPE t_key,
      i_zghsd_tabcli     TYPE t_zghsd_tabcli OCCURS 0,
      wa_zghsd_tabcli    TYPE t_zghsd_tabcli.
DATA: BEGIN OF i_garansi OCCURS 0,
        knkli     LIKE vbak-knkli,
        kdgrp     LIKE knvv-kdgrp,
        value_grs LIKE knkk-klimk,
      END OF i_garansi.
DATA: BEGIN OF i_garansi_grp OCCURS 0,
        kdgrp     LIKE knvv-kdgrp,
        value_grs LIKE knkk-klimk,
      END OF i_garansi_grp.
DATA: BEGIN OF i_kdgrp OCCURS 0,
        kdgrp LIKE knvv-kdgrp,
      END OF i_kdgrp.
RANGES: r_auart_askes FOR vbak-auart,
        r_fkart_askes FOR vbrk-fkart,
        r_vkbur FOR zsl_hsales-vkbur,
        r_knkli FOR vbak-knkli.
RANGES vbeln FOR vbak-vbeln.

DATA: va_mark1(1),
      va_mark2(1),
      va_gtext       LIKE tgsbt-gtext,
      va_vtext       LIKE tvkot-vtext,
      va_zclass      LIKE zscl_class-zclass,
      va_flag_bsm    LIKE zscl_class-flag_bsm,
      va_zvalue_high LIKE zscl_kredit-zvalue,
      va_zvalue      LIKE zscl_kredit-zvalue,
      va_zpercentage LIKE zscl_kredit-zpercentage,
      va_usergrp     LIKE zscl_top-usrgroup,
      va_zhari       LIKE zscl_top-zhari,
** Revise by budi 08/06/2006
      va_usergrp1    LIKE zscl_top-usrgroup,
      va_zhextra     LIKE zscl_top-zhextra,
      va_norut       LIKE zscl_top-zurut,
** End Revise by budi 08/06/2006
      c1             TYPE i,
      c2             TYPE i,
      c3             TYPE i,
      c4             TYPE i,
      w1             TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
      w5             TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
      w9             TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
      w13            TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
      w17            TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
      w20            TYPE i,  w17a  TYPE i,  w17b  TYPE i,
      w21            TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
      w25            TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
      w29            TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
      w33            TYPE i,  w34   TYPE i,  w35   TYPE i,  w36   TYPE i.

DATA: va_vbeln       LIKE vbak-vbeln, sw(1), va_auth(1), va_dept(1),
      va_subrc       TYPE sysubrc,
      l_credit_value LIKE wa_itab-credit_value,
      l_text(20), va_length TYPE i, va_ctr TYPE i,
      l_kunnr(10),
      l_date         LIKE sy-datum,
      l_over         LIKE wa_itab-cl_hitung,
      l_current      LIKE wa_itab-cl_current,
      l_cl_hitung    LIKE wa_itab-cl_hitung,
      l_over_value   LIKE wa_itab-cl_hitung.

** Revise By Budi 01/06/2006
DATA : i_cntre           LIKE zscr_control OCCURS 0 WITH HEADER LINE,
       i_cntrask         LIKE zscr_control OCCURS 0 WITH HEADER LINE,
       i_cntrext         LIKE zscr_control OCCURS 0 WITH HEADER LINE,
       i_cntrext01       LIKE zscr_control01 OCCURS 0 WITH HEADER LINE,
       i_cntr            LIKE zscr_control OCCURS 0 WITH HEADER LINE,
       i_zscl_backtoback LIKE zscl_backtoback OCCURS 0 WITH HEADER LINE,
       i_zsauth          LIKE zsauth OCCURS 0 WITH HEADER LINE.
** End Revise By Budi 01/06/2006

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS so_kkber LIKE knkk-kkber OBLIGATORY DEFAULT '8000'.
"MODIF ID kkb.
PARAMETERS so_vkorg LIKE vbak-vkorg OBLIGATORY DEFAULT '8020'.
PARAMETERS so_vkbur LIKE vbak-vkbur OBLIGATORY .
SELECT-OPTIONS so_kvgr3 FOR vbak-kvgr3. " OBLIGATORY .

SELECT-OPTIONS so_knkli FOR knkk-knkli.
SELECT-OPTIONS so_vbeln FOR vbak-vbeln.
SELECT-OPTIONS so_audat FOR vbak-audat.
SELECT-OPTIONS so_kdgrp FOR knvv-kdgrp.
*SELECTION-SCREEN SKIP 1.
*PARAMETERS p_vkbur LIKE vbak-vkbur.
*SELECTION-SCREEN SKIP 1.
PARAMETERS pa_auth TYPE zflag AS CHECKBOX.

*     Parameters pa_user(2) default 'BM'.
SELECTION-SCREEN END OF BLOCK block1.

*ranges r_vkbur for vbak-vkbur.
DATA: gv_auart LIKE vbak-auart.
DATA: gv_vkbur LIKE vbak-vkbur.
************************************************************************
* AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN ON so_vkorg.
  IF so_vkorg EQ '8020' OR so_vkorg EQ '8030' OR so_vkorg EQ '8070'.
  ELSE.
    MESSAGE e000(zs)
      WITH 'CoCode must be entry (8020, 8030, 8070)'.
  ENDIF.

AT SELECTION-SCREEN ON so_vkbur.
  SELECT SINGLE * FROM tvkbz
         WHERE vkbur EQ so_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e000(zs) WITH 'Sales Office Not Found'.
  ENDIF.
  IF so_vkorg EQ '8020'.
    IF so_vkbur EQ 0 OR so_vkbur EQ space OR so_vkbur+0(2) NE '02'.
      MESSAGE e000(zs) WITH 'Sales Office must be entry 02xx'.
    ENDIF.
  ELSEIF so_vkorg EQ '8030'.
    IF so_vkbur EQ 0 OR so_vkbur EQ space OR so_vkbur+0(2) NE '03'.
      MESSAGE e000(zs) WITH 'Sales Office must be entry 03xx'.
    ENDIF.
  ELSEIF so_vkorg EQ '8070'.
    IF so_vkbur EQ 0 OR so_vkbur EQ space OR so_vkbur+0(2) NE '07'.
      MESSAGE e000(zs) WITH 'Sales Office must be entry 07xx'.
    ENDIF.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
      ID 'VKBUR' FIELD so_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
     so_vkbur.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'KKB'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  PERFORM f_init_column.
  LOOP AT SCREEN.
    IF screen-group1 = 'KKB'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  IF sy-subrc EQ 0.
    so_vkorg  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'KKB'.

  IF sy-subrc EQ 0.
*    CLEAR: so_kkber, so_kkber[].
    so_kkber  = lv_parva.
*    APPEND so_kkber.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  p_time = 300.
  SET PF-STATUS '100'.
  v_repid = 'Proses Over TOP & CL Insidentil'.

  CLEAR: va_flag_bsm, va_gtext, va_vtext, va_zclass, va_usergrp, va_zhari, va_zvalue_high, va_usergrp, va_dept.

  SELECT SINGLE * INTO gs_zproject FROM zproject WHERE name = 'PPN11'.
  SELECT usergroup  INTO  va_usergrp FROM usgrp_user WHERE bname  = sy-uname.
    SELECT SINGLE usrgroup zdept INTO  (va_usergrp, va_dept) FROM zsauth WHERE usrgroup = va_usergrp.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF va_usergrp IS INITIAL.
    MESSAGE i000(zs) WITH 'Anda tidak memiliki otorisasi pengajuan form'.
    va_auth = space.
  ENDIF.
  SELECT SINGLE gtext INTO va_gtext FROM tgsbt
                 WHERE gsber EQ so_vkbur AND
                     ( spras EQ sy-langu ). "'EN' OR spras EQ 'E' ).
  SELECT SINGLE vtext INTO va_vtext FROM tvkot
            WHERE  vkorg =  so_vkorg AND
                 ( spras EQ sy-langu ). "'EN' OR spras EQ 'E' ).

  SELECT SINGLE zclass flag_bsm INTO (va_zclass, va_flag_bsm)
        FROM zscl_class
        WHERE vkbur EQ so_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e000(zs) WITH 'Table ZSCL_Class belum ada isi hub Support Center'.
    EXIT.
  ENDIF.

  SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 zurut usrgroup.

  SELECT * INTO TABLE i_zscl_kredit_user  FROM zscl_kredit
        WHERE usrgroup = va_usergrp OR
              usrgroup2 = va_usergrp OR
              usrgroup3 = va_usergrp.


  SELECT * INTO TABLE gt_zscl_trading  FROM zscl_trading.

  SELECT * INTO TABLE i_zscl_kredit  FROM zscl_kredit.
  IF sy-subrc NE 0.
    MESSAGE e000(zs) WITH 'Table ZSCL_Kredit belum ada isi hub Support Center'.
    EXIT.
  ENDIF.

  SELECT * INTO TABLE i_zsauth FROM zsauth WHERE zclass = va_zclass.
  IF sy-subrc NE 0.
    MESSAGE e000(zs) WITH 'Table ZSAUTH belum ada isi hub Support Center'.
    EXIT.
  ENDIF.
  IF so_vkorg = '8070'.
    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_zscl_top
           FROM zscl_top_sut.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'Table ZSCL_TOP_SUT belum ada isi hub Support Center'.
      EXIT.
    ENDIF.
    CLEAR: i_zscl_kredit[].
    SELECT * INTO TABLE i_zscl_kredit  FROM zscl_kredit_sut.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'Table ZSCL_Kredit_SUT belum ada isi hub Support Center'.
      EXIT.
    ENDIF.

    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_zscl_top_sut
           FROM zscl_top_sut
      WHERE usrgroup = va_usergrp OR
            usrgroup1 = va_usergrp OR
            usrgroup2 = va_usergrp.

    SELECT SINGLE zhari INTO va_zhari
          FROM zscl_top_sut
          WHERE usrgroup = va_usergrp  OR
            usrgroup1 = va_usergrp OR
            usrgroup2 = va_usergrp..
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM zscl_kredit_sut
              WHERE usrgroup = va_usergrp OR
                    usrgroup2 = va_usergrp OR
                    usrgroup3 = va_usergrp..
      IF sy-subrc NE 0.
        MESSAGE i000(zs) WITH 'Anda tidak memiliki otorisasi pengajuan form'.
      ELSE.
        va_auth = 'X'.
      ENDIF.
*      MESSAGE i000(zs) WITH 'Anda tidak memiliki otorisasi pengajuan form'.
    ELSE.
      va_auth = 'X'.
    ENDIF.
  ELSE.
* usrgroup = va_usergrp
    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_zscl_top
           FROM zscl_top_sut.
    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_zscl_top_user
           FROM zscl_top
           WHERE usrgroup = va_usergrp OR usrgroup1 = va_usergrp OR usrgroup2 = va_usergrp.

    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE i_zscl_top3
           FROM zscl_top.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'Table ZSCL_TOP belum ada isi hub Support Center'.
      EXIT.
    ENDIF.
    SELECT SINGLE zhari zhextra INTO (va_zhari, va_zhextra)
          FROM zscl_top
          WHERE usrgroup = va_usergrp.
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM zscl_kredit WHERE usrgroup = va_usergrp OR usrgroup2 = va_usergrp OR usrgroup3 = va_usergrp.
      IF sy-subrc NE 0.
        SELECT * INTO TABLE i_zscl_backtoback  FROM zscl_backtoback
          WHERE usrgroup = va_usergrp OR usrgroup1 = va_usergrp OR usrgroup2 = va_usergrp.
        IF sy-subrc NE 0.
          MESSAGE i000(zs) WITH 'Anda tidak memiliki otorisasi pengajuan form'.
        ELSE.
          va_auth = 'X'.
        ENDIF.
      ELSE.
        va_auth = 'X'.
      ENDIF.
    ELSE.
      va_auth = 'X'.
    ENDIF.
    SELECT * INTO TABLE i_zscl_backtoback  FROM zscl_backtoback.
    SELECT * INTO TABLE i_zscl_top_cross  FROM zscl_top_cross.
  ENDIF.
  IF va_usergrp IS INITIAL.
    MESSAGE i000(zs) WITH 'Anda tidak memiliki otorisasi pengajuan form'.
    va_auth = space.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsmapping_soff FROM zsmapping_soff
     WHERE vkbur1 = so_vkbur AND
           datab <= sy-datum AND
           datbi >= sy-datum.
  PERFORM f_initial_auart_askes.
  PERFORM f_get_data.
*  PERFORM f_filter_kvgr3.   "Check Auth. Object
  PERFORM f_proses_data.

  IF sy-sysid = 'DEV' OR sy-sysid = 'Q01'.
  ELSE.
    MESSAGE i002(zz) WITH 'Mohon tidak membiarkan screen diam dalam 5 menit'.
    SET USER-COMMAND 'REFR'.
  ENDIF.

****************************************************************
TOP-OF-PAGE.
*  NEW-PAGE LINE-SIZE  228.
*  NEW-PAGE LINE-SIZE  289.
  NEW-PAGE LINE-SIZE  300.
  PERFORM f_write_header.
  PERFORM f_write_column_header.
  SET LEFT SCROLL-BOUNDARY COLUMN  84.

END-OF-PAGE.

************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'REFR'.
      p_time = p_time - 10.
      CREATE OBJECT timer.
      CREATE OBJECT myh.
      timer->interval = '10'.
      CALL METHOD timer->run.
      SET HANDLER myh->run_handler FOR ALL INSTANCES.
      IF p_time = 0.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'EXECUTE'.
      CLEAR: wa_vbeln, i_vbeln, i_itab1, wa_itab.
      REFRESH: i_vbeln, i_itab1.
      LOOP AT %_list INTO va_list.
        IF va_list-line+1(1) = 'X'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_list-line+95(10) "va_list-line+78(10)
            IMPORTING
              output = va_vbeln.
          wa_vbeln-vbeln =  va_vbeln.
          APPEND  wa_vbeln TO i_vbeln .
        ENDIF.
      ENDLOOP.

      IF i_vbeln IS INITIAL.
      ELSE.
        PERFORM f_release_do_2016. " ON COMMIT.
      ENDIF.
*---------------------------------------------------*
* add by MKO to refresh screen after release
*---------------------------------------------------*
      NEW-PAGE LINE-SIZE  226.
      PERFORM f_write_header.
      PERFORM f_write_column_header.
      SET LEFT SCROLL-BOUNDARY COLUMN  84.
      PERFORM f_proses_data.

*      LOOP at i_itab into wa_itab.
**---------------------------------------------------*
** Temporer solution before we find solution to refresh data
*        Clear wa_itab-mark1.
**---------------------------------------------------*
*        PERFORM zebra.
*        PERFORM f_write_detail.
*      ENDLOOP.
*      WRITE: / sy-uline.
* end add
*---------------------------------------------------*
      REFRESH: i_vbeln, vbeln, i_itab1.
      CLEAR:   i_vbeln, vbeln, i_itab1, wa_itab.
      sy-lsind  = 0.
      p_time = 300.
    WHEN 'REQUEST'.
      CLEAR: wa_vbeln, i_vbeln, i_kunnr, so_knkli.
      REFRESH: i_vbeln, i_kunnr, so_knkli, i_form1, i_form2..
      LOOP AT %_list INTO va_list.
        IF va_list-line+4(1) = 'X'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_list-line+72(10)
            IMPORTING
              output = va_vbeln.
          wa_vbeln-vbeln =  va_vbeln.
          APPEND  wa_vbeln TO i_vbeln .
          LOOP AT i_itab INTO wa_itab WHERE vbeln = va_vbeln.
            gv_auart = wa_itab-auart.
          ENDLOOP.

          wa_kunnr-kunnr = va_list-line+23(10).
          CONDENSE wa_kunnr-kunnr.
          va_length = strlen( wa_kunnr-kunnr ).
          IF wa_kunnr-kunnr+0(2) = 'TS'
            OR va_length = '10'.
          ELSE.
            CONCATENATE '0'  wa_kunnr-kunnr INTO wa_kunnr-kunnr.
          ENDIF.
          APPEND wa_kunnr TO i_kunnr.
          so_knkli-low    = wa_kunnr-kunnr.
          so_knkli-sign   = 'I'.
          so_knkli-option = 'EQ'.
          APPEND so_knkli.
        ENDIF.
      ENDLOOP.
      PERFORM f_data_6_bulan.

      IF i_vbeln IS INITIAL.
      ELSE.
        PERFORM f_isi_data_form.

        PERFORM f_print_form.
      ENDIF.
      CLEAR: wa_vbeln, i_vbeln, i_kunnr, so_knkli.
      REFRESH: i_vbeln, i_kunnr, so_knkli, i_form1, i_form2..
      sy-lsind  = 0.
      p_time = 300.
    WHEN 'BACK'.
*      CALL FUNCTION 'DEQUEUE_ALL'.
      IF sy-lsind  = 0.
        LEAVE PROGRAM.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'SELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark1 FROM 'X'.
      ENDDO.
      p_time = 300.
    WHEN 'DESELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0. EXIT. ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark1 FROM space.
      ENDDO.
      p_time = 300.
    WHEN 'SELECT1'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark2 FROM 'X'.
      ENDDO.
      p_time = 300.
    WHEN 'DESELECT1'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0. EXIT. ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark2 FROM space.
      ENDDO.
      p_time = 300.
  ENDCASE.
************************************************************************
* AT LINE-SELECTION.
************************************************************************
************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  DATA: va_value         LIKE vbak-vbeln,
        va_fieldname(30).

  DATA: va_knkli LIKE wa_itab-knkli.
  DATA: BEGIN OF lt_rsparams OCCURS 0,
          selname(8),
          kind(1),
          sign(1),
          option(2),
          low(45),
          high(45),
        END OF lt_rsparams.
  RANGES: ra_knkli FOR  knkk-knkli,
          ra_bschl FOR bsid-umskz,
          ra_vkbur FOR tvbur-vkbur.

  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CLEAR: ra_knkli.
    REFRESH: ra_knkli.
    CASE va_fieldname.
      WHEN 'WA_ITAB-NAME1'.
        CLEAR: wa_vbeln, i_vbeln, i_kunnr, so_knkli.
        REFRESH: i_vbeln, i_kunnr, so_knkli, i_form1, i_form2.
        SET PF-STATUS '101'.
        READ CURRENT LINE FIELD VALUE : wa_itab-vbeln INTO va_vbeln
                                        wa_itab-knkli INTO wa_kunnr-kunnr
                                        wa_itab-vkbur INTO gv_vkbur
                                        wa_itab-auart INTO gv_auart.

        wa_vbeln-vbeln =  va_vbeln.
        APPEND  wa_vbeln TO i_vbeln .

*        wa_kunnr-kunnr = va_list-line+23(10).
        CONDENSE wa_kunnr-kunnr.
        va_length = strlen( wa_kunnr-kunnr ).
        IF wa_kunnr-kunnr+0(2) = 'TS'
          OR va_length = '10'.
        ELSE.
          CONCATENATE '0'  wa_kunnr-kunnr INTO wa_kunnr-kunnr.
        ENDIF.
        APPEND wa_kunnr TO i_kunnr.
        so_knkli-low    = wa_kunnr-kunnr.
        so_knkli-sign   = 'I'.
        so_knkli-option = 'EQ'.
        APPEND so_knkli.

        PERFORM f_data_6_bulan.

        IF i_vbeln IS INITIAL.
        ELSE.
          PERFORM f_isi_data_form.

          PERFORM f_print_form.
        ENDIF.
        CLEAR: wa_vbeln, i_vbeln, i_kunnr, so_knkli.
        REFRESH: i_vbeln, i_kunnr, so_knkli, i_form1, i_form2..
*        sy-lsind  = 0.
        p_time = 300.

      WHEN 'WA_ITAB-KNKLI'.
*           EXPORT va_value  TO MEMORY.
*          MEMORY ID KUN MATCHCODE OBJECT DEBI.
*                 Call transaction 'F.31'.
        ra_knkli-low = va_value.
        ra_knkli-high = va_value.
        ra_knkli-sign = 'I'.
        ra_knkli-option = 'EQ'.
        APPEND ra_knkli.
        SUBMIT rfdkli40 AND RETURN
             WITH konto IN ra_knkli.

      WHEN 'WA_ITAB-STATUS'.
        READ CURRENT LINE FIELD VALUE wa_itab-knkli INTO va_knkli.
        ra_bschl-low = 'T'.
        ra_bschl-high = 'T'.
        ra_bschl-sign = 'I'.
        ra_bschl-option = 'EQ'.
        APPEND ra_bschl.
        ra_bschl-low = 'U'.
        ra_bschl-high = 'U'.
        ra_bschl-sign = 'I'.
        ra_bschl-option = 'EQ'.
        APPEND ra_bschl.
        ra_bschl-low = 'V'.
        ra_bschl-high = 'V'.
        ra_bschl-sign = 'I'.
        ra_bschl-option = 'EQ'.
        APPEND ra_bschl.

        SUBMIT zf_ar_open_items_new_v1 AND RETURN
             WITH p_bukrs EQ so_vkorg
             WITH s_gsber EQ so_vkbur
             WITH s_kunnr EQ va_knkli
             WITH p_gerdat EQ sy-datum
             WITH x_norm  EQ 'X'
             WITH x_shbv  EQ 'X'
             WITH s_bschl IN ra_bschl
             WITH radio1  EQ 'X'.
      WHEN 'WA_ITAB-VBELN'.
        CLEAR: wa_itab.
        LOOP AT i_itab INTO wa_itab WHERE vbeln = va_value.
        ENDLOOP.
        WRITE: / 'Do #',  va_value,
                 'Dibuat pada Tanggal  : ', wa_itab-erdat,
                 'dan Jam    : ', wa_itab-erzet.
        SKIP 1.
        SELECT SINGLE * INTO wa_zghsd_tabcli FROM zghsd_tabcli2016 "zghsd_tabcli
             WHERE  vkorg  = so_vkorg
                AND vkbur  = so_vkbur
                AND kkber  = so_kkber
*                AND knkli  = wa_itab-knkli
                AND vbeln  = va_value.
        IF sy-subrc EQ 0.
          WRITE: / '  Sudah di release oleh : '.
          IF  wa_zghsd_tabcli-usergroup1 IS NOT INITIAL.
            WRITE: / '      User Group 1 : ', wa_zghsd_tabcli-usergroup1, 'User id : ', wa_zghsd_tabcli-username1,
                     '      Pada Tanggal : ', wa_zghsd_tabcli-udate1, ' dan Jam : ', wa_zghsd_tabcli-utime1.
          ENDIF.
          IF  wa_zghsd_tabcli-usergroup2 IS NOT INITIAL.
            WRITE: / '      User Group 2 : ', wa_zghsd_tabcli-usergroup2, 'User id : ', wa_zghsd_tabcli-username2,
                     '      Pada Tanggal : ', wa_zghsd_tabcli-udate2, ' dan Jam : ', wa_zghsd_tabcli-utime2.
          ENDIF.
        ENDIF.
      WHEN 'WA_ITAB-ERDAT'.
        CLEAR: wa_vbeln.
        SET PF-STATUS '101'.
        READ CURRENT LINE FIELD VALUE  wa_itab-vbeln INTO va_vbeln.
        IF sy-subrc EQ 0.
          SET PARAMETER ID 'AUN' FIELD va_vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        ENDIF.
    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_write_column_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_column_header.

  FORMAT COLOR 5.
  WRITE: / 'Sales Organisation : ', so_vkorg, ' - ', va_gtext.
  FORMAT COLOR 2.
  WRITE:   '( User Group : ',   va_usergrp, ' )'.
  FORMAT COLOR 5.
  WRITE: / 'Branch             : ', so_vkbur, ' - ', va_vtext.
  FORMAT COLOR 2.
  WRITE: '( Kelas = ', va_zclass.
  WRITE: '  Value : ', va_zvalue_high DECIMALS 0, ' )'.
  FORMAT COLOR 3.



  WRITE / sy-uline.
  c1 = 1.
  NEW-LINE.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w1 'Ch' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w1 'Ch' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'Remark Rel' 'C'. "'CL' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'Remark CL' 'C'. "'TOP' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'Remark TOP' 'C'. "'TOP' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 'Account' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 'Customer Name' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 'SCGr' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
** Revise By Budi 01/06/2006
  PERFORM f_write_text USING c1 w13 'SO Typ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
** End Revise By Budi 01/06/2006
  PERFORM f_write_text USING c1 w2 'Doc.No.#' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w20 'Status' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w13 'AccType' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Created' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
** Revise By SUK 24/09/2018 Req by Dicky

  PERFORM f_write_text USING c1 w5 'PO. Exp. Date' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
****

** Revise By Budi 01/06/2006
*     Perform f_write_text using c1 w5 'CL Current' 'C'.
  PERFORM f_write_text USING c1 '19' 'CL Current' 'C'.
** End Revise By Budi 01/06/2006
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Sales Value' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Credit Exp.' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Credit Value' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 'TOP' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 'DSO' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 '(%)' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Over Value' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 'Cred.info #' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 'Customer Name' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 'Pay' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 'Cust. SUT' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  WRITE / sy-uline.
  FORMAT COLOR 2.
ENDFORM.                    " f_write_column_header
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
** Revise By Budi 28/06/2006
*Data: l_text(14),
*      l_value like wa_itab-cl_awal.
  DATA: l_text(14),
        l_text1(20),
        l_value     LIKE wa_itab-cl_awal,
        l_value1    LIKE wa_itab-cl_current.
** End Revise By Budi 28/06/2006
  c1 = 1.
*     sw = 0.
  CONDENSE: wa_itab-remark1, wa_itab-remark2, wa_itab-remark3.
  IF wa_itab-remark1 = wa_itab-remark2.
    wa_itab-remark = wa_itab-remark1.
  ELSE.
    IF wa_itab-remark3 IS NOT INITIAL.
      CONCATENATE wa_itab-remark1 wa_itab-remark2 wa_itab-remark3
         INTO wa_itab-remark SEPARATED BY '&'.
    ELSE.
      CONCATENATE wa_itab-remark1 wa_itab-remark2
         INTO wa_itab-remark SEPARATED BY '&'.
    ENDIF.
  ENDIF.
  IF wa_itab-mark1 EQ 'X'.
    wa_itab-remark = va_usergrp.
  ENDIF.

*--------------------------------------------------------------------*
* Cek Lock Table (SO No)
*  IF va_usergrp NE 'PD'.
*    CLEAR va_subrc.
*    PERFORM f_lock_table USING wa_itab-vbeln
*                               va_dept
*                         CHANGING va_subrc.
*    IF va_subrc IS INITIAL.
*    ELSE.
*      CLEAR wa_itab-mark1.
*    ENDIF.
*  ENDIF.
*--------------------------------------------------------------------*

  WRITE / sy-vline NO-GAP.              c1 = 2.
  IF wa_itab-mark1 EQ 'X'.
    WRITE  va_mark1 AS CHECKBOX NO-GAP.   c1 = c1 + w1.
*        sw = 1.
  ELSE.
    PERFORM f_write_text USING c1 w1 space 'C'.
  ENDIF.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  IF wa_itab-mark2 EQ 'X'.
    WRITE  va_mark2 AS CHECKBOX NO-GAP.   c1 = c1 + w1.
  ELSE.
    PERFORM f_write_text USING c1 w1 space 'C'.
  ENDIF.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 wa_itab-remark 'C'. "wa_itab-remark_cl 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 wa_itab-remark_cl 'C'. " wa_itab-remark_top 'C'.                      "wa_itab-kkber 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 wa_itab-remark_top 'C'. " wa_itab-remark_top 'C'.                      "wa_itab-kkber 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 wa_itab-knkli 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 wa_itab-name1 ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
*  PERFORM f_write_text USING c1 w4 wa_itab-brsch 'C'.
  PERFORM f_write_text USING c1 w4 wa_itab-kvgr3 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
** Revise By Budi 01/06/2006
  PERFORM f_write_text USING c1 w13 wa_itab-auart 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
** End Revise By Budi 01/06/2006
  PERFORM f_write_text USING c1 w2 wa_itab-vbeln 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w20 wa_itab-status ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  PERFORM f_write_text USING c1 w13 wa_itab-blart ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

*  l_value = wa_itab-cl_awal.                                " / 1000.
*  WRITE l_value TO l_text DECIMALS 0. " CURRENCY 'IDR'.
*  PERFORM f_write_text USING c1 w5 l_text ' '.
  PERFORM f_write_text USING c1 w5 wa_itab-erdat ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 wa_itab-bnddt ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value1 = wa_itab-cl_current.                            " / 1000.
  WRITE l_value1 TO l_text1 DECIMALS 0. " CURRENCY 'IDR'.
  PERFORM f_write_text USING c1 '19' l_text1 ' '.
** End Revise By Budi 28/06/2006
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_itab-netwr.                                  " / 1000.
  WRITE l_value TO l_text DECIMALS 0. " CURRENCY 'IDR'.
  PERFORM f_write_text USING c1 w5 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_itab-credit_exposure.                        " / 1000.
  WRITE l_value TO l_text DECIMALS 0. " CURRENCY 'IDR'.
  PERFORM f_write_text USING c1 w5 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_itab-credit_value.                           " / 1000.
  WRITE l_value TO l_text DECIMALS 0. " CURRENCY 'IDR'.
  PERFORM f_write_text USING c1 w5 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  WRITE AT c1(w4)   wa_itab-top_hitung NO-GAP NO-GROUPING.
  c1 =  c1 + w4.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  WRITE AT c1(w4)   wa_itab-dso_hitung NO-GAP NO-GROUPING.
  c1 =  c1 + w4.

*     Perform f_write_text using c1 w4 wa_itab-top_hitung ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  IF wa_itab-persen > 0.
    WRITE wa_itab-persen TO l_text DECIMALS 0 NO-GROUPING.
    CONDENSE l_text.
  ELSE.
    l_text = space.
  ENDIF.
  PERFORM f_write_text USING c1 w4 l_text 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_itab-over_credit.                            " / 1000.
  WRITE l_value TO l_text DECIMALS 0. " CURRENCY 'IDR'.
  PERFORM f_write_text USING c1 w5 l_text 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w5 wa_itab-kraus 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 wa_itab-name_kraus 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w4 wa_itab-abrvw 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w2 wa_itab-altkn 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_column.
  w1   =   2.      w11 = 15.      w21 =  3.      w31 = 10.
  w2   =  10.      w12 = 15.      w22 = 10.      w32 = 40.
  w3   =  25.      w13 =  6.      w23 = 26.      w33 = 10.
  w4   =   4.      w14 = 15.      w24 = 12.      w34 = 10.
  w5   =  13.      w15 = 10.      w25 = 10.      w35 = 10.
  w6   =  10.      w16 = 12.      w26 = 10.      w36 = 50.
  w7   =  15.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  15.      w18 = 10.      w28 = 10.      w17b = 30.
  w9   =  15.      w19 = 10.      w29 = 10.
  w10  =  15.      w20 = 16.      w30 = 35.
ENDFORM.                    " f_init_column

*&---------------------------------------------------------------------*
*&      Form  f_write_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_form.
ENDFORM.                    " f_write_form

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: ctr     TYPE i, l_sw(1).
  DATA: l_numki      LIKE zsrange-numki_so,
        l_date       LIKE sy-datum,
        l_fromnumber LIKE nriv-fromnumber,
        l_nrlevel    LIKE nriv-nrlevel.
  DATA: lv_vkbur LIKE zsmapping_soff-vkbur2,
        lv_vbeln LIKE vbak-vbeln.
  RANGES: lr_auart FOR zsmapping_soff-auart, lr_vbeln FOR vbak-vbeln,
          lr_vbelntmp FOR vbak-vbeln.

  lr_vbelntmp[] = so_vbeln[].

  REFRESH: lr_auart.
  CLEAR: lv_vkbur.
  LOOP AT gt_zsmapping_soff INTO gs_zsmapping_soff.
    lv_vkbur = gs_zsmapping_soff-vkbur2.
    lr_auart-sign    = 'I'.
    lr_auart-option  = 'EQ'.
    lr_auart-low     = gs_zsmapping_soff-auart.
    APPEND lr_auart.
  ENDLOOP.

  REFRESH: i_key, i_itab2, i_itab, r_knkli, i_cntrask, lr_vbeln.
  CLEAR: wa_key, i_key, ctr, i_itab, i_itab2, i_cntrask,
         r_knkli.

* Bila nomer DO kosong, baca tabel number range sesuai cabang
  IF so_vbeln IS INITIAL.
    l_sw = 1.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ so_vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE fromnumber nrlevel
             INTO (l_fromnumber, l_nrlevel) FROM nriv
             WHERE object = 'RV_BELEG' AND
                   subobject = space AND
                   nrrangenr  = l_numki.
      IF sy-subrc EQ 0.
        so_vbeln-sign   = 'I'.
        so_vbeln-option = 'BT'.
        so_vbeln-low    = l_fromnumber.
        so_vbeln-high   = l_nrlevel+10(10).
        APPEND so_vbeln.
      ENDIF.

      IF so_vkbur = '0245'. "'0201'.
        CLEAR so_vbeln[].
        so_vbeln-sign   = 'I'.
        so_vbeln-option = 'CP'.
        CONCATENATE l_fromnumber(3) '*' INTO lv_vbeln.
        so_vbeln-low    = lv_vbeln.
        so_vbeln-high   = space.
        APPEND so_vbeln.
      ENDIF.

*      IF so_vkbur = '0252' OR
*        so_vkbur = '0223' OR
*        so_vkbur = '0230'.
*        CLEAR so_vbeln[].
*        so_vbeln-sign   = 'I'.
*        so_vbeln-option = 'CP'.
*        CONCATENATE l_fromnumber(3) '*' INTO lv_vbeln.
*        so_vbeln-low    = lv_vbeln.
*        so_vbeln-high   = space.
*        APPEND so_vbeln.
*
*        IF so_vkbur = '0230'.
*          CLEAR: so_vbeln,lv_vbeln.
*          so_vbeln-sign   = 'I'.
*          so_vbeln-option = 'CP'.
*          lv_vbeln = '112*'.
*          so_vbeln-low    = lv_vbeln.
*          so_vbeln-high   = space.
*          APPEND so_vbeln.
*        ENDIF.
*      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst EQ 'B'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.
  IF ctr <= 0.
*    MESSAGE s000(zs) WITH 'Data Not Found'.
*    LEAVE LIST-PROCESSING.
  ELSE.
    SELECT a~vkorg a~vkbur a~vtweg a~kunnr a~knkli a~kkber a~vbeln a~bnddt
          a~erdat a~erzet a~netwr a~audat a~abrvw
          c~name1 c~brsch e~zterm e~altkn a~auart a~kvgr3 a~kvgr4 f~kdgrp
          INTO CORRESPONDING FIELDS OF TABLE i_itab
          FROM vbak AS a JOIN kna1 AS c  ON c~kunnr EQ a~knkli
                         JOIN knvv AS b  ON b~kunnr EQ a~knkli
                         JOIN knb1 AS e  ON e~kunnr EQ a~knkli AND
                                            e~bukrs EQ a~vkorg
                         JOIN vbkd AS f  ON f~vbeln EQ a~vbeln
              FOR ALL ENTRIES IN i_key
          WHERE a~vbeln EQ i_key-vbeln AND
                a~kkber EQ so_kkber    AND
                a~knkli IN so_knkli    AND
                a~vkorg EQ so_vkorg    AND
                a~vkbur EQ so_vkbur    AND
                b~vkbur EQ so_vkbur    AND
                a~audat IN so_audat    AND
                f~kdgrp IN so_kdgrp    AND
                a~kvgr3 IN so_kvgr3.
*  IF sy-subrc NE 0.
*    MESSAGE s000(zs) WITH 'Data Not Found'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
    SORT i_itab BY vbeln.
    DELETE ADJACENT DUPLICATES FROM i_itab COMPARING vbeln.
  ENDIF.

*  IF so_vbeln IS INITIAL.
  l_sw = 1.
  CLEAR: l_numki, l_nrlevel, l_fromnumber.
  SELECT SINGLE numki_so FROM zsrange
         INTO l_numki
         WHERE vkbur EQ lv_vkbur.
  IF sy-subrc = 0.
    SELECT SINGLE fromnumber nrlevel
           INTO (l_fromnumber, l_nrlevel) FROM nriv
           WHERE object = 'RV_BELEG' AND
                 subobject = space AND
                 nrrangenr  = l_numki.
    IF sy-subrc EQ 0.
      lr_vbeln-sign = 'I'.
      lr_vbeln-option = 'BT'.
      lr_vbeln-low = l_fromnumber.
      lr_vbeln-high = l_nrlevel+10(10).
      APPEND lr_vbeln.
    ENDIF.
  ENDIF.
*  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst EQ 'B'.

  DELETE i_key WHERE NOT ( vbeln IN lr_vbeln ).

  IF lr_vbelntmp[] IS NOT INITIAL.
    DELETE i_key WHERE NOT ( vbeln IN lr_vbelntmp ).
  ENDIF.

  DESCRIBE TABLE i_key LINES ctr.
  IF ctr <= 0.
*****    MESSAGE s000(zs) WITH 'Data Not Found'.
*****    LEAVE LIST-PROCESSING.
  ELSE.
    IF lv_vkbur NE so_vkbur.
      SELECT a~vkorg a~vkbur a~vtweg a~kunnr a~knkli a~kkber a~vbeln a~bnddt
            a~erdat a~erzet a~netwr a~audat
            c~name1 c~brsch e~zterm e~altkn a~auart a~kvgr3 a~kvgr4 f~kdgrp
            INTO CORRESPONDING FIELDS OF TABLE i_itab3
            FROM vbak AS a JOIN kna1 AS c  ON c~kunnr EQ a~knkli
                           JOIN knb1 AS e  ON e~kunnr EQ a~knkli AND
                                              e~bukrs EQ a~vkorg
                           JOIN vbkd AS f  ON f~vbeln EQ a~vbeln
                FOR ALL ENTRIES IN i_key
            WHERE a~vbeln EQ i_key-vbeln AND
                  a~kkber EQ so_kkber    AND
                  a~knkli IN so_knkli    AND
                  a~vkorg EQ so_vkorg    AND
                  a~vkbur EQ lv_vkbur    AND
                  a~audat IN so_audat    AND
                  a~auart IN lr_auart    AND
                  f~kdgrp IN so_kdgrp.
      IF sy-subrc EQ 0.
        i_itab2[] = i_itab3[].
        SORT i_itab2 BY kunnr.
        DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING kunnr.
*{   REPLACE        P01K910258                                        1
*\        SELECT * INTO CORRESPONDING FIELDS OF TABLE i_kunnr FROM knvv
*\          FOR ALL ENTRIES IN i_itab2
*\          WHERE kunnr = i_itab2-kunnr AND
*\                vkbur = so_vkbur  AND
*\                vkorg = so_vkorg.
        "Start SOH: Shell SCI Adjustment 20240221 KS
        SELECT * INTO CORRESPONDING FIELDS OF TABLE i_kunnr FROM knvv
          FOR ALL ENTRIES IN i_itab2
          WHERE kunnr = i_itab2-kunnr AND
                vkbur = so_vkbur  AND
                vkorg = so_vkorg
          ORDER BY PRIMARY KEY.
        "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE
        IF sy-subrc EQ 0.
          LOOP AT i_kunnr INTO wa_kunnr.
            LOOP AT i_itab3 INTO wa_itab WHERE kunnr = wa_kunnr-kunnr.
              wa_itab-vkbur = so_vkbur.
              APPEND wa_itab TO i_itab.
              CLEAR wa_itab.
            ENDLOOP.
          ENDLOOP.
        ELSE.
          REFRESH: i_itab3.
        ENDIF.
        REFRESH: i_kunnr, i_itab3, i_itab2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF i_itab[] IS INITIAL.
    MESSAGE s000(zs) WITH 'Data Not Found'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  IF so_vkorg = '8070'.
    PERFORM f_get_data_8070.
  ELSE.
    PERFORM f_get_data_8020.
  ENDIF.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data.
  DATA: l_belnr         LIKE bsid-belnr,
        l_zfbdt         LIKE bsid-zfbdt,
        l_zbd1t         LIKE bsid-zbd1t,
        l_zbd1t1        LIKE bsid-zbd1t,
        l_fkart         LIKE vbrk-fkart,
        l_flag_top      LIKE wa_itab-flag_top,
        l_date          LIKE sy-datum,
        l_zrange1(2),
        l_zrange2(2),
        l_top           TYPE i,
        l_top1          TYPE i,
        l_top2          TYPE i,
        l_dso           TYPE i,
        l_topsut        TYPE verzn,
        l_dsosut        TYPE verzn,
        l_zbd1tsut      TYPE dzbd1t,
        l_blart         LIKE bsid-blart,
        lv_sysubr       LIKE sy-subrc,
        l_sw(1),
        l_i             TYPE i,
        l_flaggarasi(1),
        l_remark        LIKE wa_itab-remark,
        l_usergrp       LIKE va_usergrp,
        l_userbm        LIKE va_usergrp,
        l_userbsm       LIKE va_usergrp,
        l_value         TYPE wertv10,
        l_exposure      LIKE knkk-klimk,
        l_exposure_sut  LIKE knkk-klimk,
        l_bank_garansi  LIKE knkk-klimk,
        lv_kunnr        LIKE kna1-kunnr,
        l_dept(1).
  DATA:  lva_zhextra LIKE zscl_backtoback-zhextra.
  DATA: lv_ceklevel(1),
        lv_lvltop1     LIKE zsauth-zcode,
        lv_lvltop2     LIKE zsauth-zcode,
        lv_lvltop3     LIKE zsauth-zcode,
        lv_lvlcl1      LIKE zsauth-zcode,
        lv_lvlcl2      LIKE zsauth-zcode,
        lv_lvlcl3      LIKE zsauth-zcode.
  DATA: lva_zpercentage LIKE zscl_kredit-zpercentage.
  DATA: wa_knkk_sut TYPE knkk.
  CLEAR: l_usergrp, va_zpercentage, va_zvalue.

  l_userbm = 'BM'.
  l_userbsm = 'BSM'.
  LOOP AT i_zscl_kredit INTO wa_zscl_kredit.
    IF wa_zscl_kredit-usrgroup = va_usergrp.
      va_zvalue = wa_zscl_kredit-zvalue * 100.
      va_zpercentage = wa_zscl_kredit-zpercentage.
    ENDIF.
    IF wa_zscl_kredit-usrgroup2 = va_usergrp.
      va_zvalue = wa_zscl_kredit-zvalue * 100.
      va_zpercentage = wa_zscl_kredit-zpercentage.
    ENDIF.
    IF wa_zscl_kredit-usrgroup3 = va_usergrp.
      va_zvalue = wa_zscl_kredit-zvalue * 100.
      va_zpercentage = wa_zscl_kredit-zpercentage.
    ENDIF.
    IF wa_zscl_kredit-usrgroup = l_userbm.
      va_zvalue_high = wa_zscl_kredit-zvalue * 100.
    ENDIF.
    IF wa_zscl_kredit-usrgroup2 = l_userbm.
      va_zvalue_high = wa_zscl_kredit-zvalue * 100.
    ENDIF.
    IF wa_zscl_kredit-usrgroup3 = l_userbm.
      va_zvalue_high = wa_zscl_kredit-zvalue * 100.
    ENDIF.
  ENDLOOP.

  IF va_zvalue = 0.
    va_zvalue = va_zvalue_high.
  ENDIF.
  REFRESH: i_garansi.
  CLEAR: i_garansi.
  lva_zpercentage = va_zpercentage.
  SORT i_itab BY knkli kkber vbeln.
  LOOP AT i_itab INTO wa_itab.
**    IF va_usergrp = 'TTSH'.
**      IF wa_itab-kvgr3 NE '05T'.
**        CONTINUE.
**      ENDIF.
**    ENDIF.
*-----------------------------------------------*
* add by MKO to reset credit limit calculation
    va_zpercentage = lva_zpercentage.
    IF wa_itab-status <> 'CLEAR' AND wa_itab-postst <> 'X'.
      IF wa_itab-status <> ''.
        CLEAR : wa_itab-cl_awal, wa_itab-cl_current,
                wa_itab-cl_hitung, wa_itab-credit_exposure,
                wa_itab-ar, wa_itab-credit_value,
                wa_itab-over_credit, wa_itab-persen,
                wa_itab-flagtop, wa_itab-flagcl,
                wa_itab-authtop, wa_itab-authcl,
                wa_itab-mark1, wa_itab-mark2,
                wa_itab-flag_top, wa_itab-reason,
                wa_itab-status.
        CALL FUNCTION 'Z_PPN11'
          EXPORTING
            pi_wrbtr = wa_itab-netwr
            pi_calty = 'S1'
            pi_datum = wa_itab-erdat
          IMPORTING
            po_wrbtr = wa_itab-netwr.
        "        wa_itab-netwr = wa_itab-netwr * ( 10 / 1100 ).

****** GH:AB SUK - Project Alignment
*** Proses cek top untuk customer sut yg pindah ke PTT ( 06 feb 2026 ).
        IF wa_itab-altkn IS NOT INITIAL.
          CLEAR: l_exposure_sut.
          CALL FUNCTION 'CREDIT_EXPOSURE'
            EXPORTING
              kkber     = '8070'
              kunnr     = wa_itab-altkn "wa_itab-knkli
            IMPORTING
              sum_opens = l_exposure_sut
              e_knkk    = wa_knkk_sut.
        ENDIF.

        CLEAR: l_exposure.
        CALL FUNCTION 'CREDIT_EXPOSURE'
          EXPORTING
            kkber     = wa_itab-kkber
            kunnr     = wa_itab-knkli
          IMPORTING
            sum_opens = l_exposure
            e_knkk    = knkk.
        l_exposure = l_exposure + l_exposure_sut.
      ENDIF.
*-----------------------------------------------*
      ON CHANGE OF wa_itab-knkli OR
                   wa_itab-kkber.
****** GH:AB SUK - Project Alignment
*** Proses cek top untuk customer sut yg pindah ke PTT ( 06 feb 2026 ).
        CLEAR: l_exposure_sut.
        IF wa_itab-altkn IS NOT INITIAL.
          CALL FUNCTION 'CREDIT_EXPOSURE'
            EXPORTING
              kkber     = '8070' "wa_itab-kkber
              kunnr     = wa_itab-altkn "wa_itab-knkli
            IMPORTING
              sum_opens = l_exposure_sut
              e_knkk    = wa_knkk_sut.
        ENDIF.

        CLEAR: l_exposure.
        CALL FUNCTION 'CREDIT_EXPOSURE'
          EXPORTING
            kkber     = wa_itab-kkber
            kunnr     = wa_itab-knkli
          IMPORTING
            sum_opens = l_exposure
            e_knkk    = knkk.
        l_exposure = l_exposure + l_exposure_sut.
      ENDON.
      wa_itab-kraus = knkk-kraus.
      IF wa_itab-kraus IS NOT INITIAL.
        CLEAR: lv_kunnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = knkk-kraus
          IMPORTING
            output = lv_kunnr.
        SELECT SINGLE name1 INTO wa_itab-name_kraus FROM kna1 WHERE kunnr = lv_kunnr.
      ENDIF.
      CLEAR: l_belnr, l_zfbdt, l_zbd1t, l_date, l_fkart,
             l_top, l_top1, l_top2, l_flag_top, l_zbd1t1,
             l_blart.
      CLEAR: i_cntr, l_sw, i_zscl_top_cross.
      SORT i_zscl_top_cross BY kvgr3.
      READ TABLE i_zscl_top_cross WITH KEY kvgr3 = wa_itab-kvgr3
      BINARY SEARCH.
      IF sy-subrc NE 0.
        SORT i_zscl_top_cross BY kdgrp.
        READ TABLE i_zscl_top_cross WITH KEY kdgrp = wa_itab-kdgrp
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          l_top2 = i_zscl_top_cross-zdso. "70.
          l_sw = 'C'.
        ENDIF.
      ELSE.
        l_top2 = i_zscl_top_cross-zdso. "70.
        l_sw = 'C'.
      ENDIF.
      READ TABLE i_cntr WITH KEY auart = wa_itab-auart.
      IF i_cntr-stat1 = 'A'.  "Khusus TOP Reguler
        "Khusus order type ZT9D tidak mempengaruhi top reguler
        LOOP AT i_kunnr INTO wa_kunnr WHERE kunnr = wa_itab-knkli AND
                                            stat1 <> 'I'.  "Stat1 = 'I' khusus order type ZT9D
          IF l_top =< wa_kunnr-top.
            l_top = wa_kunnr-top.
            l_zbd1t1 = wa_kunnr-zbd1t.
            l_blart  = wa_kunnr-blart.
          ENDIF.
          IF wa_kunnr-flag_top IS NOT INITIAL.
            l_flag_top  = wa_kunnr-flag_top.
          ENDIF.
        ENDLOOP.
        IF l_sw = 'C'.
          LOOP AT i_kunnr INTO wa_kunnr WHERE kunnr = wa_itab-knkli AND
                                              stat1 = 'I'.  "Stat1 = 'I' khusus order type ZT9D
            IF l_top1 =< wa_kunnr-top.
              l_top1 = wa_kunnr-top.
              l_dso = wa_kunnr-l_top.
              l_zbd1t1 = wa_kunnr-zbd1t.
              l_blart  = wa_kunnr-blart.
            ENDIF.
          ENDLOOP.
          IF l_dso > l_top2.
            IF l_top < l_top1.
              l_top = l_top1.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE. " TOP Khusus termasuk 'ZT9D'
        LOOP AT i_kunnr INTO wa_kunnr WHERE kunnr = wa_itab-knkli AND
                                            stat1 = i_cntr-stat1.
          IF l_top =< wa_kunnr-top.
            l_top = wa_kunnr-top.
            l_zbd1t1 = wa_kunnr-zbd1t.
            l_blart  = wa_kunnr-blart.
          ENDIF.
        ENDLOOP.
        SORT i_zscl_top_cross BY auart.
        READ TABLE i_zscl_top_cross WITH KEY auart = wa_itab-auart
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF l_sw = 'C'.
            LOOP AT i_kunnr INTO wa_kunnr WHERE kunnr = wa_itab-knkli.
              IF l_top1 =< wa_kunnr-top.
                l_top1 = wa_kunnr-top.
                l_dso = wa_kunnr-l_top.
                l_zbd1t1 = wa_kunnr-zbd1t.
                l_blart  = wa_kunnr-blart.
              ENDIF.
            ENDLOOP.
            IF l_dso > l_top2.
              IF l_top < l_top1.
                l_top = l_top1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
**        IF wa_itab-kvgr3 eq '036' and wa_itab-auart eq 'ZT9D'.
***Khusus order type ZT9D dan Group 036 akan cek reguler jika TOP lebih dari 75 hari
**        ENDIF.
      ENDIF.
****** GH:AB SUK - Project Alignment
*** Proses cek top untuk customer sut yg pindah ke PTT ( 06 feb 2026 ).
      CLEAR: l_topsut, l_dsosut, l_zbd1tsut.
      IF wa_itab-altkn IS NOT INITIAL.
        CALL FUNCTION 'ZDG2_CUSTOMER_OLDEST_OPEN_ITEM'
          EXPORTING
            companycode = '8070'
            customer    = wa_itab-altkn
            keydate     = sy-datum
          IMPORTING
            verzn       = l_topsut
            dso         = l_dsosut
            zbd1t       = l_zbd1tsut.
        l_top1 = l_topsut.
        IF l_top < l_top1.
          l_top1 = l_dso - l_top.
          l_top = l_topsut.
          IF l_dsosut > l_dso.
            l_dso = l_dsosut.
          ENDIF.
        ENDIF.
      ENDIF.
***** Check Kena CL
      wa_itab-kunnr           = wa_itab-knkli.
      wa_itab-credit_exposure = l_exposure * 100.
      wa_itab-ar              = knkk-skfor.
      wa_itab-cl_awal         = knkk-dbekr.
      wa_itab-cl_current      = knkk-klimk * 100.
      CALL FUNCTION 'Z_PPN11'
        EXPORTING
          pi_wrbtr = wa_itab-netwr
          pi_calty = 'S2'
          pi_datum = wa_itab-erdat
        IMPORTING
          po_wrbtr = wa_itab-netwr.
      "      wa_itab-netwr           = wa_itab-netwr * ( 1100 / 10 ).
      wa_itab-credit_value    = wa_itab-credit_exposure + wa_itab-netwr.
***** Check Bank Garasi
***   Jika ada bank garansi maka dicek tanggal jatuh tempo dan masa berlakuknya
***   Jika masa berlakunya sudah exp. maka order akan ke block dgn status remark GRS
***   Jika masih berlaku maka akan dicek apakah credit value lebih besar dari bank garansi
***   jika iya makan akan diblock dengan status remark GRS jika tidak maka akan mengikuti aturan yg sudah berjalan

      IF so_vkorg = '8020'.  "Bank garansi hanya ada di PTT (8020)
        IF wa_itab-auart(3) = 'ZOT' OR wa_itab-auart(2) = 'ZT'. .
          CLEAR: l_flaggarasi, l_bank_garansi.
          SORT i_zsbankgrs BY kunnr.
          LOOP AT i_zsbankgrs INTO wa_zsbankgrs WHERE kunnr = wa_itab-knkli.
            IF wa_zsbankgrs-valid_to >= sy-datum AND wa_zsbankgrs-valid_fr <= sy-datum.
              l_flaggarasi = 'V'.
              IF wa_zsbankgrs-waers = 'IDR'.
                l_bank_garansi = l_bank_garansi + ( wa_zsbankgrs-wrbtr * 100 ).
              ELSE.
                l_bank_garansi = l_bank_garansi + wa_zsbankgrs-wrbtr.
              ENDIF.
            ELSE.
              IF wa_zsbankgrs-valid_fr >= sy-datum.
                IF l_flaggarasi = 'V' OR l_flaggarasi = 'G'.
                ELSE.
                  l_flaggarasi = 'B'.
                ENDIF.
              ELSE.
                IF l_flaggarasi = 'V'.
                ELSE.
                  l_flaggarasi = 'G'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF l_flaggarasi = space AND knkk-klimk NE 1.
            SORT i_zsbankgrp BY kdgrp.
            CLEAR: l_bank_garansi, l_flaggarasi.
            LOOP AT i_zsbankgrp INTO wa_zsbankgrs WHERE kdgrp = wa_itab-kdgrp.
              IF wa_zsbankgrs-valid_to >= sy-datum AND wa_zsbankgrs-valid_fr <= sy-datum.
                l_flaggarasi = 'V'.
                IF wa_zsbankgrs-waers = 'IDR'.
                  l_bank_garansi = wa_zsbankgrs-wrbtr * 100.
                ELSE.
                  l_bank_garansi = wa_zsbankgrs-wrbtr.
                ENDIF.
                EXIT.
              ELSE.
                IF wa_zsbankgrs-valid_fr >= sy-datum.
                  IF l_flaggarasi = 'V' OR l_flaggarasi = 'G'.
                  ELSE.
                    l_flaggarasi = 'B'.
                  ENDIF.
                ELSE.
                  IF l_flaggarasi = 'V'.
                  ELSE.
                    l_flaggarasi = 'G'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
          IF l_flaggarasi = 'V'.
            IF wa_itab-credit_value > l_bank_garansi.
              l_flaggarasi =  'G'.
            ELSE.
              i_garansi-knkli    = wa_itab-knkli.
              i_garansi-kdgrp    = wa_itab-kdgrp.
              i_garansi-value_grs = l_bank_garansi.
              APPEND i_garansi.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: l_flaggarasi.
      ENDIF.
***      IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***        IF va_usergrp = 'MDDD' OR va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
***          va_zpercentage = 99999.
***           va_zvalue_high = va_zvalue = 9999999999.
***        ENDIF.
***      ENDIF.

      wa_itab-cl_hitung       = wa_itab-cl_current + va_zvalue.
      IF wa_itab-credit_value > wa_itab-cl_current.
        wa_itab-over_credit     = wa_itab-credit_value - wa_itab-cl_current.
        IF wa_itab-cl_current NE 0.
          wa_itab-persen  = ( wa_itab-over_credit / wa_itab-cl_current ) * 100.
        ELSE.
          wa_itab-persen  = wa_itab-over_credit.
        ENDIF.
        wa_itab-flagcl    = 'X'.
      ELSE.
        wa_itab-flagcl    = space.
        wa_itab-over_credit = 0.
        wa_itab-persen  =  0.
      ENDIF.
      " tambahan hardcode untuk order type ZT9D tidak cek CL
      " tgl 2 jan 2018
      IF wa_itab-auart = 'ZT9D'.
        wa_itab-flagcl    = space.
        wa_itab-over_credit = 0.
        wa_itab-persen  =  0.
        wa_itab-over_credit = 0.
        wa_itab-credit_exposure = 0.
        wa_itab-ar              = 0.
        wa_itab-credit_value    = 0.
      ENDIF.
      wa_itab-authcl   = space.
****** check punya auth cl or not
      IF wa_itab-credit_value > wa_itab-cl_hitung.
        wa_itab-authcl   = space.
        IF wa_itab-over_credit > va_zvalue.
          wa_itab-authcl    = space.
        ELSE.
          IF wa_itab-over_credit <= va_zvalue_high.
            wa_itab-authcl    = 'X'.
          ELSE.
            IF va_zpercentage >= wa_itab-persen.
              wa_itab-authcl    = 'X'.
            ELSE.
              wa_itab-authcl    = space.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF va_zpercentage > 999.
          wa_itab-authcl    = 'X'.
        ELSE.
*          IF wa_itab-persen > 100.
          IF wa_itab-persen > va_zpercentage.
            wa_itab-authcl   = space.
            IF wa_itab-over_credit <= va_zvalue_high.
              wa_itab-authcl    = 'X'.
            ELSE.
              wa_itab-authcl    = space.
            ENDIF.
          ELSE.
            IF wa_itab-over_credit <= va_zvalue.
              wa_itab-authcl    = 'X'.
            ELSE.
              CLEAR: wa_itab-authcl.
            ENDIF.
          ENDIF.
        ENDIF.
**        IF wa_itab-over_credit > va_zvalue.
**          IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
**            IF va_usergrp = 'MDDD' OR va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
**              wa_itab-authcl = 'X'.
**            ENDIF.
**          ENDIF.
**        ENDIF.
      ENDIF.

***** Check kena TOP
      IF l_zbd1t1 < l_zbd1tsut.
        l_zbd1t1 = l_zbd1tsut.
      ENDIF.
      wa_itab-zbd1t = l_zbd1t1.
      IF l_top < 0.
        wa_itab-top = 0.
      ELSE.
        wa_itab-top = l_top.
        wa_itab-top_hitung = l_top.
        wa_itab-flag_top = l_flag_top.
        wa_itab-blart    = l_blart.
      ENDIF.
      IF wa_itab-top_hitung > 99.
        wa_itab-top = 99.
      ENDIF.
      wa_itab-dso_hitung = wa_itab-top_hitung + wa_itab-zbd1t.
      wa_itab-dso = wa_itab-top + wa_itab-zbd1t.
      IF wa_itab-dso_hitung > 99.
        wa_itab-dso = 99.
      ENDIF.

**** Buat Status
      IF wa_itab-top NE 0.
        wa_itab-flagtop = 'X'.
        wa_itab-status = 'TOP'.
      ELSE.
        wa_itab-authtop = 'X'.
      ENDIF.

      IF wa_itab-credit_value > wa_itab-cl_current.
        wa_itab-flagcl = 'X'.
        CONDENSE wa_itab-status.
        IF wa_itab-status NE space.
          CONCATENATE 'CL' wa_itab-status INTO wa_itab-status
                SEPARATED BY ','.
        ELSE.
          wa_itab-status = 'CL'.
        ENDIF.
      ENDIF.

      IF l_flaggarasi =  'G'. " AND va_usergrp NE 'PD'.
        wa_itab-remark = 'GRS'.
        wa_itab-remark_cl = 'GRS'.
        wa_itab-remark_top = 'GRS'.
        wa_itab-remark_cl1 = 'GRS'.
        wa_itab-remark_cl2 = 'GRS'.
        wa_itab-remark_top1 = 'GRS'.
        wa_itab-remark_top2 = 'GRS'.
        wa_itab-mark1  = space.
        wa_itab-mark2  = 'X'.         "munculkan checkbox pengajuan tg.29.01.2014
        IF va_usergrp EQ 'PD'.
          wa_itab-mark2  = space.
          wa_itab-mark1  = 'X'.         "munculkan checkbox pengajuan tg.29.01.2014
        ENDIF.

        CLEAR: l_sw, l_flaggarasi.
        IF pa_auth = 'X'.
          IF wa_itab-mark1 NE 'X'.
            CONTINUE.
          ENDIF.
        ENDIF.

        l_i = 4.
        PERFORM zebra USING l_i.
        PERFORM f_write_detail.
        MODIFY i_itab FROM wa_itab.
        CLEAR: wa_itab.
        CONTINUE.
      ENDIF.

      CLEAR: zghsd_tabcli2016, lv_sysubr.
      SELECT SINGLE * FROM zghsd_tabcli2016
            WHERE vkorg = wa_itab-vkorg
              AND vkbur = wa_itab-vkbur
              AND kkber = wa_itab-kkber
              AND knkli = wa_itab-knkli
              AND vbeln = wa_itab-vbeln.
      lv_sysubr = sy-subrc.
      IF lv_sysubr EQ 0.
        IF zghsd_tabcli2016-usergroup1 IS NOT INITIAL.
          SELECT SINGLE zdept INTO l_dept FROM zsauth WHERE usrgroup = zghsd_tabcli2016-usergroup1.
        ELSEIF zghsd_tabcli2016-usergroup2 IS NOT INITIAL.
          SELECT SINGLE zdept INTO l_dept FROM zsauth WHERE usrgroup = zghsd_tabcli2016-usergroup2.
        ENDIF.
        IF l_dept = va_dept.
          "no autro
        ENDIF.
      ENDIF.
*** Check punya auth TOP or Not
      IF wa_itab-flagtop = 'X'.
        IF va_usergrp = 'PD'.
          wa_itab-authtop = 'X'. "wa_itab-authtop = 'X'.
        ENDIF.
        IF so_vkorg = '8020'.
          IF wa_itab-kvgr3 = '03' AND wa_itab-auart = 'ZT9D'.
            SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3.
            READ TABLE i_zscl_backtoback WITH KEY kkber = so_kkber
                                       auart = wa_itab-auart
                                       kdgrp = wa_itab-kdgrp
                                       kvgr3 = wa_itab-kvgr3
            BINARY SEARCH.
          ELSE.
            SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3.
            READ TABLE i_zscl_backtoback WITH KEY kkber = so_kkber
                                       auart = wa_itab-auart
                                       kdgrp = wa_itab-kdgrp
                                       kvgr3 = wa_itab-kvgr3
            BINARY SEARCH.
            IF sy-subrc NE 0.
              SORT i_zscl_backtoback BY kkber auart kdgrp.
              READ TABLE i_zscl_backtoback WITH KEY kkber = so_kkber
                                         auart = wa_itab-auart
                                         kdgrp = wa_itab-kdgrp
              BINARY SEARCH.
            ENDIF.
          ENDIF.
          IF sy-subrc EQ 0.
            wa_itab-backtoback = 'X'.
            CLEAR: wa_itab-flagtop.
            CLEAR: wa_itab-authback, wa_itab-authtop.
            "           REPLACE 'TOP'  WITH 'BACK' INTO wa_itab-status.
            IF wa_itab-auart(3) = 'ZT7'.
              REPLACE 'TOP'  WITH 'ER' INTO wa_itab-status.
            ELSE.
              REPLACE 'TOP'  WITH 'BACK' INTO wa_itab-status.
            ENDIF.
          ENDIF.
          IF wa_itab-backtoback = 'X'.
            CLEAR: lva_zhextra.
            PERFORM f_cek_backtoback  USING    so_kkber wa_itab-auart wa_itab-kdgrp wa_itab-kvgr3 va_usergrp
                                      CHANGING lva_zhextra sy-subrc.
            IF sy-subrc EQ 0.
              IF lva_zhextra >= wa_itab-top.
                wa_itab-authback = 'X'. "
              ELSE.
                CLEAR: wa_itab-authback.
              ENDIF.
            ENDIF.
          ENDIF.
          CONDENSE: wa_itab-status.
          IF wa_itab-authtop NE 'X' AND wa_itab-backtoback NE 'X'.
            PERFORM f_cek_auth_top CHANGING wa_itab-authtop wa_itab-dso wa_itab-top.
          ENDIF.
          IF wa_itab-authtop = space.
            PERFORM f_cek_remark_top CHANGING wa_itab-remark_top1 wa_itab-remark_top2 wa_itab-remark_top3 wa_itab-remark_top.
          ELSE.
            PERFORM f_cek_remark_top CHANGING wa_itab-remark_top1 wa_itab-remark_top2 wa_itab-remark_top3 wa_itab-remark_top.
            IF va_usergrp NE wa_itab-remark_top1 AND va_usergrp NE wa_itab-remark_top2 AND va_usergrp NE wa_itab-remark_top3.
              LOOP AT i_zsauth.
                IF i_zsauth-usrgroup = va_usergrp.
                  IF i_zsauth-zdept = '1'.
                    wa_itab-remark_top1 = va_usergrp.
                  ELSEIF i_zsauth-zdept = '2'.
                    wa_itab-remark_top2 = va_usergrp.
                  ELSEIF i_zsauth-zdept = '3'.           "tambahan jika sampai 3 dept
                    wa_itab-remark_top3 = va_usergrp.
                  ENDIF.
                ENDIF.
                CLEAR: i_zsauth.
              ENDLOOP.
            ENDIF.
            wa_itab-mark1 = 'X'.
          ENDIF.
        ENDIF.
        IF so_vkorg = '8070'.
          PERFORM f_cek_auth_top CHANGING wa_itab-authtop wa_itab-dso wa_itab-top.
          IF wa_itab-authtop = space.
            PERFORM f_cek_remark_top CHANGING wa_itab-remark_top1 wa_itab-remark_top2 wa_itab-remark_top3 wa_itab-remark_top.
          ELSE.
            PERFORM f_cek_remark_top CHANGING wa_itab-remark_top1 wa_itab-remark_top2 wa_itab-remark_top3 wa_itab-remark_top.
            IF va_usergrp NE wa_itab-remark_top1 AND va_usergrp NE wa_itab-remark_top2.
              LOOP AT i_zsauth.
                IF i_zsauth-usrgroup = va_usergrp.
                  IF i_zsauth-zdept = '1'.
                    wa_itab-remark_top1 = va_usergrp.
                  ELSEIF i_zsauth-zdept = '2'.
                    wa_itab-remark_top2 = va_usergrp.
                  ELSEIF i_zsauth-zdept = '3'.           "tambahan jika samai 3 dept
                    wa_itab-remark_top3 = va_usergrp.
                  ENDIF.
                ENDIF.
                CLEAR: i_zsauth.
              ENDLOOP.
            ENDIF.
            wa_itab-mark1 = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
************ Jika tidak kena TOP
        wa_itab-authtop = 'X'.
      ENDIF.
* Jika punya auth b2b maka ada auth untuk top
      IF wa_itab-authback = 'X'.
        wa_itab-authtop = 'X'.
        IF va_dept = '1'.
          wa_itab-remark_top1 = va_usergrp.
        ENDIF.
        IF va_dept = '2'.
          wa_itab-remark_top2 = va_usergrp.
        ENDIF.
        IF va_dept = '3'.
          wa_itab-remark_top3 = va_usergrp.
        ENDIF.
      ENDIF.
*** Check auth cl
      IF wa_itab-flagcl = 'X'.
        IF wa_itab-authcl = 'X'.   " Jika punya auth CL
          PERFORM f_cek_remark_cl CHANGING wa_itab-remark_cl.
          IF va_usergrp NE wa_itab-remark_cl1 AND va_usergrp NE wa_itab-remark_cl2.
            LOOP AT i_zsauth.
              IF i_zsauth-usrgroup = va_usergrp.
                IF i_zsauth-zdept = '1'.
                  wa_itab-remark_cl1 = va_usergrp.
                ELSEIF i_zsauth-zdept = '2'.
                  wa_itab-remark_cl2 = va_usergrp.
                ELSEIF i_zsauth-zdept = '3'.   "Tambahan jika 3 dept
                  wa_itab-remark_cl3 = va_usergrp.
                ENDIF.
              ENDIF.
              CLEAR: i_zsauth.
            ENDLOOP.
          ENDIF.
          wa_itab-mark1 = 'X'.
*** Jika ke TOP juga
          IF wa_itab-flagtop = 'X'.
*** Jika TOP tidak ada auth
            IF wa_itab-authtop NE 'X'.
              CLEAR: wa_itab-mark1.
            ENDIF.
          ENDIF.
        ELSE. " Jika tidak punya auth CL
          PERFORM f_cek_remark_cl CHANGING wa_itab-remark_cl.
***          IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***            IF va_usergrp = 'MDDD' OR va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
***              wa_itab-authcl = 'X'.
***              wa_itab-authtop = 'X'.
***            ENDIF.
***          ENDIF.
        ENDIF.
      ELSE.
        IF wa_itab-authtop = 'X'.
          wa_itab-mark1 = 'X'.
        ENDIF.
      ENDIF.
**** Cek Level Authorisasi anatara CL dan TOP

      CLEAR: lv_ceklevel.
      IF wa_itab-flagtop = 'X' AND wa_itab-flagcl = 'X'.
*** Untuk kondisi TOP dan CL
        lv_ceklevel = '1'.
        IF wa_itab-authtop = 'X' AND wa_itab-authcl = 'X'.
          wa_itab-mark1 = 'X'.
        ELSE.
          wa_itab-mark1 = space.
        ENDIF.
      ENDIF.
      IF wa_itab-flagtop = 'X' AND wa_itab-flagcl NE 'X'.
*** Untuk kondisi TOP dan tidak CL
        wa_itab-remark1 = wa_itab-remark_top1.
        wa_itab-remark2 = wa_itab-remark_top2.
        wa_itab-remark3 = wa_itab-remark_top3.
        IF wa_itab-authtop = 'X'.
          wa_itab-mark1 = 'X'.
        ELSE.
          wa_itab-mark1 = space.
        ENDIF.
      ENDIF.
      IF wa_itab-flagtop NE 'X' AND wa_itab-flagcl EQ 'X'.
*** Untuk kondisi tidak TOP dan CL
        wa_itab-remark1 = wa_itab-remark_cl1.
        wa_itab-remark2 = wa_itab-remark_cl2.
        wa_itab-remark3 = wa_itab-remark_cl3.
        IF wa_itab-authcl = 'X'.
          wa_itab-mark1 = 'X'.
        ELSE.
          wa_itab-mark1 = space.
        ENDIF.
      ENDIF.
      IF wa_itab-flagtop NE 'X' AND wa_itab-flagcl NE 'X'.
*** Untuk kondisi tidak kena TOP dan tidak kena CL
        wa_itab-mark1 = 'X'.
        IF wa_itab-backtoback = 'X'.
*** Kena BACK to Back
          CLEAR: wa_itab-mark1.
          wa_itab-status = 'BACK'.
          IF wa_itab-auart(3) = 'ZT7'. " OR wa_itab-auart = 'ZT7B'.
            wa_itab-status = 'ER'.
          ENDIF.
          IF wa_itab-authback = 'X'.
            wa_itab-mark1 = 'X'.
            wa_itab-remark1 = wa_itab-remark_top1.
            wa_itab-remark2 = wa_itab-remark_top2.
            wa_itab-remark3 = wa_itab-remark_top3.
          ELSE.
            wa_itab-remark1 = wa_itab-remark_top1.
            wa_itab-remark2 = wa_itab-remark_top2.
            wa_itab-remark3 = wa_itab-remark_top3.
          ENDIF.
        ELSE.
*** Untuk kondisi tidak kena TOP dan tidak kena CL
          wa_itab-mark1 = 'X'.
          wa_itab-status = 'CLEAR'.
          wa_itab-remark = wa_itab-remark1 = wa_itab-remark2 = wa_itab-remark3 = va_usergrp.
        ENDIF.
*        CLEAR: wa_itab-remark1, wa_itab-remark2.
      ENDIF.
      IF wa_itab-backtoback = 'X'.
        IF wa_itab-remark_top EQ 'B2B' OR wa_itab-remark_top1 EQ 'B2B'.
          wa_itab-remark1 = wa_itab-remark_top1.
          wa_itab-remark2 = wa_itab-remark_top2.
          wa_itab-remark3 = wa_itab-remark_top3.
          wa_itab-remark  = 'B2B'.
          CLEAR: wa_itab-authcl, wa_itab-authtop, wa_itab-authback, wa_itab-mark1, wa_itab-mark2.
        ELSE.
          IF wa_itab-flagcl = 'X'.
            lv_ceklevel = '1'.
            IF wa_itab-authback = 'X' AND wa_itab-authcl = 'X'.
              wa_itab-mark1 = 'X'.
            ELSE.
              wa_itab-mark1 =  space.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_ceklevel = '1'.
        CLEAR: lv_lvltop1, lv_lvltop2, lv_lvltop3,
               lv_lvlcl1, lv_lvlcl2, lv_lvlcl3.
        IF wa_itab-remark_top1 IS NOT INITIAL AND wa_itab-remark_top2 IS NOT INITIAL.
          IF wa_itab-remark_top3 IS INITIAL.
            wa_itab-remark_top3 = wa_itab-remark_top1.
          ENDIF.
        ENDIF.
        IF wa_itab-remark_cl1 IS NOT INITIAL AND wa_itab-remark_cl2 IS NOT INITIAL.
          IF wa_itab-remark_cl3 IS INITIAL.
            wa_itab-remark_cl3 = wa_itab-remark_cl1.
          ENDIF.
        ENDIF.

        LOOP AT i_zsauth.
          IF wa_itab-remark_top1 = i_zsauth-usrgroup.
            lv_lvltop1 = i_zsauth-zcode.
          ENDIF.
          IF wa_itab-remark_top2 = i_zsauth-usrgroup.
            lv_lvltop2 = i_zsauth-zcode.
          ENDIF.
          IF wa_itab-remark_top3 = i_zsauth-usrgroup.
            lv_lvltop3 = i_zsauth-zcode.
          ENDIF.
          IF wa_itab-remark_cl1 = i_zsauth-usrgroup.
            lv_lvlcl1 = i_zsauth-zcode.
          ENDIF.
          IF wa_itab-remark_cl2 = i_zsauth-usrgroup.
            lv_lvlcl2 = i_zsauth-zcode.
          ENDIF.
          IF wa_itab-remark_cl3 = i_zsauth-usrgroup.
            lv_lvlcl3 = i_zsauth-zcode.
          ENDIF.
          CLEAR: i_zsauth.
        ENDLOOP.
        IF wa_itab-remark_top1 EQ space.
          lv_lvltop1 = 0.
        ENDIF.
        IF wa_itab-remark_top2 EQ space.
          lv_lvltop2 = 0.
        ENDIF.
        IF wa_itab-remark_top3 EQ space.
          lv_lvltop3 = 0.
        ENDIF.
        IF wa_itab-remark_cl1 EQ space.
          lv_lvlcl1 = 0.
        ENDIF.
        IF wa_itab-remark_cl2 EQ space.
          lv_lvlcl2 = 0.
        ENDIF.
        IF wa_itab-remark_cl3 EQ space.
          lv_lvlcl3 = 0.
        ENDIF.

        IF lv_lvltop1 < lv_lvlcl1.
          wa_itab-remark1 = wa_itab-remark_cl1.
        ELSE.
          wa_itab-remark1 = wa_itab-remark_top1.
        ENDIF.
        IF lv_lvltop2 < lv_lvlcl2.
          wa_itab-remark2 = wa_itab-remark_cl2.
        ELSE.
          wa_itab-remark2 = wa_itab-remark_top2.
        ENDIF.
        IF lv_lvltop3 < lv_lvlcl3.
          wa_itab-remark3 = wa_itab-remark_cl3.
        ELSE.
          wa_itab-remark3 = wa_itab-remark_top3.
        ENDIF.
        IF wa_itab-remark3 = wa_itab-remark1.
          CLEAR: wa_itab-remark3.
        ENDIF.
        IF wa_itab-remark_cl1 = wa_itab-remark_cl3.
          CLEAR: wa_itab-remark_cl3.
        ENDIF.
        IF wa_itab-remark_top1 = wa_itab-remark_top3.
          CLEAR: wa_itab-remark_top3.
        ENDIF.
      ENDIF.

*** Cek ke table release untuk memastikan do sdh pernah direlease
      IF lv_sysubr EQ 0.
        CLEAR: l_dept.
        LOOP AT i_zsauth.
          IF zghsd_tabcli2016-usergroup1 = i_zsauth-usrgroup.
            l_dept = i_zsauth-zdept.
            EXIT.
          ENDIF.
          IF zghsd_tabcli2016-usergroup2 = i_zsauth-usrgroup.
            l_dept = i_zsauth-zdept.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF l_dept = va_dept.
          IF wa_itab-status = 'CLEAR'.
            wa_itab-mark1 = 'X'.
            wa_itab-remark = wa_itab-remark1 = wa_itab-remark2 = wa_itab-remark3 = va_usergrp.
          ELSE.
            CLEAR: wa_itab-mark1.
            CLEAR: wa_itab-authtop,  wa_itab-authcl, wa_itab-authback.
          ENDIF.
        ENDIF.
        IF zghsd_tabcli2016-usergroup1 IS NOT INITIAL.
          CONCATENATE wa_itab-status zghsd_tabcli2016-usergroup1
               INTO wa_itab-status SEPARATED BY ','.
        ENDIF.
        IF zghsd_tabcli2016-usergroup2 IS NOT INITIAL.
          CONCATENATE wa_itab-status zghsd_tabcli2016-usergroup2
               INTO wa_itab-status SEPARATED BY ','.
        ENDIF.
** Jika semua user sudah direlease maka status diganti jadi clear dan bisa direlease siapa saja.
        IF zghsd_tabcli2016-usergroup1 IS NOT INITIAL AND zghsd_tabcli2016-usergroup2 IS NOT INITIAL.
          wa_itab-mark1 = 'X'.
*          wa_itab-status = 'CLEAR'.
*          CLEAR: wa_itab-remark1, wa_itab-remark2, wa_itab-remark3.
        ENDIF.
      ENDIF.
*      IF va_usergrp NE wa_itab-remark1 AND va_usergrp NE wa_itab-remark2 AND va_usergrp NE wa_itab-remark3.
*        CLEAR: wa_itab-mark1.
*      ENDIF.
      IF wa_itab-status NE 'CLEAR'.
        IF wa_itab-remark1 IS INITIAL.
          IF wa_itab-backtoback = 'X'.
          ELSE.
            wa_itab-remark = wa_itab-remark1 = 'PD'.
          ENDIF.
        ENDIF.
      ENDIF.
      IF l_flag_top = 'A' OR wa_itab-flag_top = 'A'.  "Jika Kena ASKES
        wa_itab-mark1 = space.
        wa_itab-remark = 'BPJS'.
        wa_itab-remark1 = 'BPJS'.
        wa_itab-remark2 = 'BPJS'.
        wa_itab-remark3 = 'BPJS'.
        wa_itab-remark_top1 = 'BPJS'.
        wa_itab-remark_top2 = 'BPJS'.
        wa_itab-remark_top3 = 'BPJS'.
        wa_itab-remark_cl1  = 'BPJS'.
        wa_itab-remark_cl2  = 'BPJS'.
        wa_itab-remark_cl3  = 'BPJS'.
        wa_itab-remark_cl = 'BPJS'.
        wa_itab-remark_top = 'BPJS'.
      ENDIF.

      IF va_auth = space.
        wa_itab-mark1 = space.
      ENDIF.

      IF wa_itab-mark2 = 'X'.
        IF va_auth = space.
          wa_itab-mark2 = space.
        ENDIF.
        IF va_usergrp NE 'BM' AND va_usergrp NE 'BSM'.
          wa_itab-mark2 = space.
        ENDIF.
      ELSE.
*************************************** Yang Boleh mengajukan form Release
        IF va_auth NE space AND wa_itab-mark1 = space.
          SELECT SINGLE * FROM zsauth
                 WHERE usrgroup = va_usergrp AND
                       zcode <= 4.
          IF sy-subrc EQ 0 AND wa_itab-postst EQ space.
* Remark by MKO for fixing BM repeating release same order (not valid)
            IF wa_itab-remark = 'B2B'.
              wa_itab-mark2 = space.
            ELSE.
              wa_itab-mark2 = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF l_flaggarasi = 'G'.
        wa_itab-remark = 'GRS'.
        wa_itab-remark1 = 'GRS'.
        wa_itab-remark2 = 'GRS'.
        wa_itab-remark3 = 'GRS'.
        wa_itab-remark_top1 = 'GRS'.
        wa_itab-remark_top2 = 'GRS'.
        wa_itab-remark_top3 = 'GRS'.
        wa_itab-remark_cl1  = 'GRS'.
        wa_itab-remark_cl2  = 'GRS'.
        wa_itab-remark_cl3  = 'GRS'.
        wa_itab-mark1  = space.
        wa_itab-mark2  = space.
      ENDIF.
      IF va_usergrp EQ 'PD' AND wa_itab-backtoback NE 'X'.
        wa_itab-mark1 = 'X'.
        wa_itab-mark2 = space.
        wa_itab-remark = 'PD'.
        wa_itab-remark1 = space.
        wa_itab-remark2 = space.
        wa_itab-remark3 = space.
      ENDIF.
      IF wa_itab-mark1 = 'X' OR wa_itab-mark2 = 'X'.
        AUTHORITY-CHECK OBJECT 'ZSUBCUST'
            ID 'ZKVGR3' FIELD wa_itab-kvgr3.
        IF sy-subrc NE 0.
          wa_itab-remark = 'NOT'.
          wa_itab-remark1 = 'NOT'.
          wa_itab-remark2 = 'NOT'.
          wa_itab-remark_cl = 'NOT'.
          wa_itab-remark_top = 'NOT'.
          wa_itab-mark1  = space.
          wa_itab-mark2  = space.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: l_sw.
    wa_itab-zflagcl = wa_itab-flagcl.
    wa_itab-zflagtop = wa_itab-flagtop.
    wa_itab-zflagback = wa_itab-backtoback.
    MODIFY i_itab FROM wa_itab.
    IF pa_auth = 'X'.
      IF wa_itab-mark1 NE 'X'.
        CONTINUE.
      ENDIF.
    ENDIF.
    l_i = 2.
    PERFORM zebra USING l_i.
    IF wa_itab-auart(3) = 'ZT7'. " OR wa_itab-auart = 'ZT7B'.
      IF wa_itab-remark = 'B2B'.
        wa_itab-remark1 = wa_itab-remark2 = wa_itab-remark = 'ER'.
      ENDIF.
    ENDIF.
***    IF wa_itab-mark1 EQ 'X' AND wa_itab-kvgr3 = '05T'.
***      SORT gt_zscl_trading BY kvgr3 usrgroup.
***      READ TABLE gt_zscl_trading INTO gs_zscl_trading WITH KEY
***      kvgr3 = wa_itab-kvgr3
***      usrgroup = va_usergrp
***      BINARY SEARCH.
***      IF sy-subrc EQ 0.
***      ELSE.
***        CLEAR: wa_itab-mark1.
***      ENDIF.
***    ENDIF.
    PERFORM f_write_detail.
    MODIFY i_itab FROM wa_itab.
    CLEAR: wa_itab.
  ENDLOOP.
  WRITE: / sy-uline.
ENDFORM.                    " f_proses_data


*&---------------------------------------------------------------------*
*&      Form  f_write_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C  text
*      -->P_W  text
*      -->P_S  text
*----------------------------------------------------------------------*
FORM f_write_text USING    p_c TYPE i
                           p_w TYPE i
                           p_s
                           p_t.
  IF p_t = 'C'.
    WRITE AT p_c(p_w)  p_s NO-GAP  CENTERED.
  ELSE.
    WRITE AT p_c(p_w)  p_s NO-GAP.
  ENDIF.
  p_c = p_c + p_w.

ENDFORM.                    " f_write_text
*&---------------------------------------------------------------------*
*&      Form  f_write_collumn_header1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_collumn_header1.
  DATA: l_no(25).
*     Write: / 'Permohonan Otorisasi Toleransi Over TOP Internal'.
  WRITE: / 'No. : '.
  c1 = 7.
  WRITE AT c1(w32)  l_no INPUT ON NO-GAP. c1 = c1 + w32.

  POSITION v_right.
  WRITE: '( 000 )'.
  FORMAT COLOR 3 INTENSIFIED OFF.

  WRITE / sy-uline.
  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 'No' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 'Cust Code' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 'Nama Outlet' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-1' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-2' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-3' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-4' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-5' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'M-6' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'Avr Sales' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  PERFORM f_write_text USING c1 w24 'Act Sales' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.


  PERFORM f_write_text USING c1 w24 'AR-1' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-2' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-3' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-4' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-5' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-6' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  PERFORM f_write_text USING c1 w24 'Avr AR' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  WRITE / sy-uline.
  FORMAT COLOR 2.
ENDFORM.                    " f_write_collumn_header1
*&---------------------------------------------------------------------*
*&      Form  f_write_collumn_header11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_collumn_header11.
  DATA: l_no(25).

  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  WRITE AT 148 sy-uline(78).  c1 = 226.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  FORMAT COLOR 3 INTENSIFIED OFF.

  PERFORM f_write_text USING c1 w24 'AR-7' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-8' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-9' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-10' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-11' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 'AR-12' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  FORMAT COLOR 2.

  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.


  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  WRITE AT 148 sy-uline(78).  c1 = 226.
  PERFORM f_write_text USING c1 w24 ' ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
ENDFORM.                    " f_write_collumn_header11
*&---------------------------------------------------------------------*
*&      Form  f_write_detail1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail1.
  DATA: l_text(10), l_reason(25),
        l_value LIKE wa_itab-cl_awal.

  c1 = 1.
  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 wa_form1-znou ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 wa_form1-kunnr ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 wa_form1-name1 ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_form1-m1 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m2 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m3 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m4 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m5 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m6 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-avrm / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-m0 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_form1-ar1 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar2 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar3 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar4 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar5 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar6 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-avrar / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

ENDFORM.                    " f_write_detail1

*&---------------------------------------------------------------------*
*&      Form  f_write_detail11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail11.
  DATA: l_text(10), l_reason(25),
        l_value LIKE wa_itab-cl_awal.

  c1 = 1.
  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w21 '' '   '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w22 '' '         '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w23 '' '                         '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_form1-ar7 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar8 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar9 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar10 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar11 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form1-ar12 / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w24 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w24 '' '            '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
ENDFORM.                    " f_write_detail11

*&---------------------------------------------------------------------*
*&      Form  f_initial_auart_askes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initial_auart_askes.
  REFRESH: r_auart_askes.
  CLEAR: r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT2A'.
  r_auart_askes-high   = 'ZT2A'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT2B'.
  r_auart_askes-high   = 'ZT2B'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT2C'.
  r_auart_askes-high   = 'ZT2C'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT2C'.
  r_auart_askes-high   = 'ZT2C'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT9A'.
  r_auart_askes-high   = 'ZT9A'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT9B'.
  r_auart_askes-high   = 'ZT9B'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT9C'.
  r_auart_askes-high   = 'ZT9C'.
  APPEND r_auart_askes.
*** Remark 03 01 2018 karna ada pengecekkan khusus bukan katergory BPJS
*  r_auart_askes-sign   = 'I'.
*  r_auart_askes-option = 'EQ'.
*  r_auart_askes-low    = 'ZT9D'.
*  r_auart_askes-high   = 'ZT9D'.
*  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZT9F'.
  r_auart_askes-high   = 'ZT9F'.
  APPEND r_auart_askes.

  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA2A'.
  r_auart_askes-high   = 'ZA2A'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA2B'.
  r_auart_askes-high   = 'ZA2B'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA2C'.
  r_auart_askes-high   = 'ZA2C'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA2D'.
  r_auart_askes-high   = 'ZA2D'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA9A'.
  r_auart_askes-high   = 'ZA9A'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA9B'.
  r_auart_askes-high   = 'ZA9B'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA9C'.
  r_auart_askes-high   = 'ZA9C'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA9D'.
  r_auart_askes-high   = 'ZA9D'.
  APPEND r_auart_askes.
  r_auart_askes-sign   = 'I'.
  r_auart_askes-option = 'EQ'.
  r_auart_askes-low    = 'ZA9F'.
  r_auart_askes-high   = 'ZA9F'.
  APPEND r_auart_askes.

  REFRESH: r_fkart_askes.
  CLEAR: r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB2A'.
  r_fkart_askes-high   = 'ZB2A'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB2B'.
  r_fkart_askes-high   = 'ZB2B'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB2C'.
  r_fkart_askes-high   = 'ZB2C'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB2D'.
  r_fkart_askes-high   = 'ZB2D'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9A'.
  r_fkart_askes-high   = 'ZB9A'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9B'.
  r_fkart_askes-high   = 'ZB9B'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9C'.
  r_fkart_askes-high   = 'ZB9C'.
  APPEND r_fkart_askes.
*** Remark 03 01 2018 karna ada pengecekkan khusus bukan katergory BPJS
*  r_fkart_askes-sign   = 'I'.
*  r_fkart_askes-option = 'EQ'.
*  r_fkart_askes-low    = 'ZB9D'.
*  r_fkart_askes-high   = 'ZB9D'.
*  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9F'.
  r_fkart_askes-high   = 'ZB9F'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9G'.
  r_fkart_askes-high   = 'ZB9G'.
  APPEND r_fkart_askes.
  r_fkart_askes-sign   = 'I'.
  r_fkart_askes-option = 'EQ'.
  r_fkart_askes-low    = 'ZB9H'.
  r_fkart_askes-high   = 'ZB9H'.
  APPEND r_fkart_askes.

ENDFORM.                    " f_initial_auart_askes
*&---------------------------------------------------------------------*
*&      Form  f_isi_itab_tmp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_isi_itab_tmp .
  DATA: l_date     LIKE sy-datum,
        l_ar1      LIKE wa_knc1-um01u,
        l_ar2      LIKE wa_knc1-um01u,
        l_ar3      LIKE wa_knc1-um01u,
        l_ar4      LIKE wa_knc1-um01u,
        l_ar5      LIKE wa_knc1-um01u,
        l_ar6      LIKE wa_knc1-um01u,
        l_ar7      LIKE wa_knc1-um01u,
        l_ar8      LIKE wa_knc1-um01u,
        l_ar9      LIKE wa_knc1-um01u,
        l_ar10     LIKE wa_knc1-um01u,
        l_ar11     LIKE wa_knc1-um01u,
        l_ar12     LIKE wa_knc1-um01u,
        l_avrar    LIKE wa_knc1-um01u,
        l_field    TYPE char10,
        l_int      TYPE i,
        l_char(2),
        l_count(3) TYPE n,
        l_year(4)  TYPE n,
        l_year1(4) TYPE n,
        l_spmon0   LIKE s603-spmon,
        l_spmon1   LIKE s603-spmon,
        l_spmon2   LIKE s603-spmon,
        l_spmon3   LIKE s603-spmon,
        l_spmon4   LIKE s603-spmon,
        l_spmon5   LIKE s603-spmon,
        l_spmon6   LIKE s603-spmon,
        l_month(2) TYPE n.
  FIELD-SYMBOLS: <fs_field> TYPE any.

* Current Month
  l_spmon0 = sy-datum(6).

* Month - 1
  l_count = 1.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.

  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon1 = l_date(6).

  SORT i_knc1 BY kunnr gjahr.
  READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                          gjahr = l_year.
  CASE l_month.
    WHEN 01.
      l_ar1 = wa_knc1-um01u.
    WHEN 02.
      l_ar1 = wa_knc1-um02u.
    WHEN 03.
      l_ar1 = wa_knc1-um03u.
    WHEN 04.
      l_ar1 = wa_knc1-um04u.
    WHEN 05.
      l_ar1 = wa_knc1-um05u.
    WHEN 06.
      l_ar1 = wa_knc1-um06u.
    WHEN 07.
      l_ar1 = wa_knc1-um07u.
    WHEN 08.
      l_ar1 = wa_knc1-um08u.
    WHEN 09.
      l_ar1 = wa_knc1-um09u.
    WHEN 10.
      l_ar1 = wa_knc1-um10u.
    WHEN 11.
      l_ar1 = wa_knc1-um11u.
    WHEN 12.
      l_ar1 = wa_knc1-um12u.
  ENDCASE.

* Month - 2
  l_count = 2.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.
  l_year1 =  l_year.
  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon2 = l_date(6).
  IF l_year1 = l_year.
  ELSE.
    SORT i_knc1 BY kunnr gjahr.
    READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                            gjahr = l_year.
  ENDIF.
  CASE l_month.
    WHEN 01.
      l_ar2 = wa_knc1-um01u.
    WHEN 02.
      l_ar2 = wa_knc1-um02u.
    WHEN 03.
      l_ar2 = wa_knc1-um03u.
    WHEN 04.
      l_ar2 = wa_knc1-um04u.
    WHEN 05.
      l_ar2 = wa_knc1-um05u.
    WHEN 06.
      l_ar2 = wa_knc1-um06u.
    WHEN 07.
      l_ar2 = wa_knc1-um07u.
    WHEN 08.
      l_ar2 = wa_knc1-um08u.
    WHEN 09.
      l_ar2 = wa_knc1-um09u.
    WHEN 10.
      l_ar2 = wa_knc1-um10u.
    WHEN 11.
      l_ar2 = wa_knc1-um11u.
    WHEN 12.
      l_ar2 = wa_knc1-um12u.
  ENDCASE.

* Month - 3
  l_count = 3.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.
  l_year1 =  l_year.
  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon3 = l_date(6).
  IF l_year1 = l_year.
  ELSE.
    SORT i_knc1 BY kunnr gjahr.
    READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                            gjahr = l_year.
  ENDIF.
  CASE l_month.
    WHEN 01.
      l_ar3 = wa_knc1-um01u.
    WHEN 02.
      l_ar3 = wa_knc1-um02u.
    WHEN 03.
      l_ar3 = wa_knc1-um03u.
    WHEN 04.
      l_ar3 = wa_knc1-um04u.
    WHEN 05.
      l_ar3 = wa_knc1-um05u.
    WHEN 06.
      l_ar3 = wa_knc1-um06u.
    WHEN 07.
      l_ar3 = wa_knc1-um07u.
    WHEN 08.
      l_ar3 = wa_knc1-um08u.
    WHEN 09.
      l_ar3 = wa_knc1-um09u.
    WHEN 10.
      l_ar3 = wa_knc1-um10u.
    WHEN 11.
      l_ar3 = wa_knc1-um11u.
    WHEN 12.
      l_ar3 = wa_knc1-um12u.
  ENDCASE.

* Month - 4
  l_count = 4.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.
  l_year1 =  l_year.
  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon4 = l_date(6).
  IF l_year1 = l_year.
  ELSE.
    SORT i_knc1 BY kunnr gjahr.
    READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                            gjahr = l_year.
  ENDIF.
  CASE l_month.
    WHEN 01.
      l_ar4 = wa_knc1-um01u.
    WHEN 02.
      l_ar4 = wa_knc1-um02u.
    WHEN 03.
      l_ar4 = wa_knc1-um03u.
    WHEN 04.
      l_ar4 = wa_knc1-um04u.
    WHEN 05.
      l_ar4 = wa_knc1-um05u.
    WHEN 06.
      l_ar4 = wa_knc1-um06u.
    WHEN 07.
      l_ar4 = wa_knc1-um07u.
    WHEN 08.
      l_ar4 = wa_knc1-um08u.
    WHEN 09.
      l_ar4 = wa_knc1-um09u.
    WHEN 10.
      l_ar4 = wa_knc1-um10u.
    WHEN 11.
      l_ar4 = wa_knc1-um11u.
    WHEN 12.
      l_ar4 = wa_knc1-um12u.
  ENDCASE.

* Month - 5
  l_count = 5.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.
  l_year1 =  l_year.
  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon5 = l_date(6).
  IF l_year1 = l_year.
  ELSE.
    SORT i_knc1 BY kunnr gjahr.
    READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                            gjahr = l_year.
  ENDIF.
  CASE l_month.
    WHEN 01.
      l_ar5 = wa_knc1-um01u.
    WHEN 02.
      l_ar5 = wa_knc1-um02u.
    WHEN 03.
      l_ar5 = wa_knc1-um03u.
    WHEN 04.
      l_ar5 = wa_knc1-um04u.
    WHEN 05.
      l_ar5 = wa_knc1-um05u.
    WHEN 06.
      l_ar5 = wa_knc1-um06u.
    WHEN 07.
      l_ar5 = wa_knc1-um07u.
    WHEN 08.
      l_ar5 = wa_knc1-um08u.
    WHEN 09.
      l_ar5 = wa_knc1-um09u.
    WHEN 10.
      l_ar5 = wa_knc1-um10u.
    WHEN 11.
      l_ar5 = wa_knc1-um11u.
    WHEN 12.
      l_ar5 = wa_knc1-um12u.
  ENDCASE.

* Month - 6
  l_count = 6.
  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = l_count
    IMPORTING
      newdate    = l_date.
  l_year1 =  l_year.
  l_month = l_date+4(2).
  l_year  = l_date(4).
  l_spmon6 = l_date(6).
  IF l_year1 = l_year.
  ELSE.
    SORT i_knc1 BY kunnr gjahr.
    READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                            gjahr = l_year.
  ENDIF.
  CASE l_month.
    WHEN 01.
      l_ar6 = wa_knc1-um01u.
    WHEN 02.
      l_ar6 = wa_knc1-um02u.
    WHEN 03.
      l_ar6 = wa_knc1-um03u.
    WHEN 04.
      l_ar6 = wa_knc1-um04u.
    WHEN 05.
      l_ar6 = wa_knc1-um05u.
    WHEN 06.
      l_ar6 = wa_knc1-um06u.
    WHEN 07.
      l_ar6 = wa_knc1-um07u.
    WHEN 08.
      l_ar6 = wa_knc1-um08u.
    WHEN 09.
      l_ar6 = wa_knc1-um09u.
    WHEN 10.
      l_ar6 = wa_knc1-um10u.
    WHEN 11.
      l_ar6 = wa_knc1-um11u.
    WHEN 12.
      l_ar6 = wa_knc1-um12u.
  ENDCASE.

  DO 6 TIMES.
    CLEAR l_field.
    ADD 1 TO l_count.
    l_int = l_count.
    l_char = l_int.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = sy-datum
        backmonths = l_count
      IMPORTING
        newdate    = l_date.

    l_year1 =  l_year.
    l_month = l_date+4(2).
    l_year  = l_date(4).
    l_spmon6 = l_date(6).

    IF l_year1 = l_year.
    ELSE.
      SORT i_knc1 BY kunnr gjahr.
      READ TABLE i_knc1 INTO wa_knc1 WITH KEY kunnr = wa_itab-kunnr
                                              gjahr = l_year.
    ENDIF.

    CONCATENATE 'L_AR' l_char INTO l_field.
    ASSIGN (l_field) TO <fs_field>.

    CASE l_month.
      WHEN 01.
        <fs_field> = wa_knc1-um01u.
      WHEN 02.
        <fs_field> = wa_knc1-um02u.
      WHEN 03.
        <fs_field> = wa_knc1-um03u.
      WHEN 04.
        <fs_field> = wa_knc1-um04u.
      WHEN 05.
        <fs_field> = wa_knc1-um05u.
      WHEN 06.
        <fs_field> = wa_knc1-um06u.
      WHEN 07.
        <fs_field> = wa_knc1-um07u.
      WHEN 08.
        <fs_field> = wa_knc1-um08u.
      WHEN 09.
        <fs_field> = wa_knc1-um09u.
      WHEN 10.
        <fs_field> = wa_knc1-um10u.
      WHEN 11.
        <fs_field> = wa_knc1-um11u.
      WHEN 12.
        <fs_field> = wa_knc1-um12u.
    ENDCASE.
  ENDDO.

  wa_form1-ar1 = l_ar1 * 100.
  wa_form1-ar2 = l_ar2 * 100.
  wa_form1-ar3 = l_ar3 * 100.
  wa_form1-ar4 = l_ar4 * 100.
  wa_form1-ar5 = l_ar5 * 100.
  wa_form1-ar6 = l_ar6 * 100.
  wa_form1-ar7 = l_ar7 * 100.
  wa_form1-ar8 = l_ar8 * 100.
  wa_form1-ar9 = l_ar9 * 100.
  wa_form1-ar10 = l_ar10 * 100.
  wa_form1-ar11 = l_ar11 * 100.
  wa_form1-ar12 = l_ar12 * 100.
*  wa_form1-avrar = ( wa_form1-ar1 + wa_form1-ar2 + wa_form1-ar3 +
*                        wa_form1-ar4 + wa_form1-ar5 + wa_form1-ar6  ) / 6.
  wa_form1-avrar = ( wa_form1-ar1 + wa_form1-ar2 + wa_form1-ar3 +
                     wa_form1-ar4 + wa_form1-ar5 + wa_form1-ar6 +
                     wa_form1-ar7 + wa_form1-ar8 + wa_form1-ar9 +
                     wa_form1-ar10 + wa_form1-ar11 + wa_form1-ar12  ) / 12.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon0.
  wa_form1-m0 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon1.
  wa_form1-m1 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon2.
  wa_form1-m2 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon3.
  wa_form1-m3 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon4.
  wa_form1-m4 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon5.
  wa_form1-m5 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.
  SORT i_s603 BY pkunwe spmon.
  CLEAR: wa_s603.
  READ TABLE i_s603 INTO wa_s603 WITH KEY pkunwe = wa_itab-kunnr
                                          spmon = l_spmon6.
  wa_form1-m6 = ( wa_s603-umkzwi1 + wa_s603-gukzwi1 ) * 100.

  wa_form1-avrm = ( wa_form1-m1 + wa_form1-m2 + wa_form1-m3 +
                        wa_form1-m4 + wa_form1-m5 + wa_form1-m6  ) / 6.
ENDFORM.                    " f_isi_itab_tmp
*&---------------------------------------------------------------------*
*&      Form  f_write_collumn_header2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_collumn_header2 .
  WRITE / sy-uline.
  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w35 'No. SO' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w25 'CL Awal' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w26 'CL Current' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w27 'Over Value' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w28 'Over %' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w29 'Saldo A/R' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c2 = w30 - 5.
  PERFORM f_write_text USING c1 c2 'Kemampuan Bayar Outlet' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w31 'Over TOP' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c2 = w32 - 5.
  PERFORM f_write_text USING c1 c2 'Alasan Permohonan' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w33 'Disetujui Rp' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w34 '%' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w3 'Keterangan ' 'C'.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w35 'sub Cust.' 'C'.
*  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
  WRITE / sy-uline.
ENDFORM.                    " f_write_collumn_header2
*&---------------------------------------------------------------------*
*&      Form  f_write_detail2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail2 .
  DATA: l_text(10), l_reason(25), l_mampu(25),
        l_value LIKE wa_itab-cl_awal.

  c1 = 1.
  WRITE / sy-vline NO-GAP.              c1 = 2.
  PERFORM f_write_text USING c1 w35 wa_form2-vbeln ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  l_value = wa_form2-cl_awal / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w25 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form2-cl_current / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w26 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form2-over_credit / 1000.
  WRITE l_value TO l_text DECIMALS 0.
  PERFORM f_write_text USING c1 w27 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form2-persen.
  WRITE l_value TO l_text DECIMALS 2.
  CONDENSE l_text.
  CONCATENATE l_text '%' INTO l_text SEPARATED BY space.
  PERFORM f_write_text USING c1 w28 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  l_value = wa_form2-ar / 1000.
  WRITE l_value TO l_text CURRENCY 'IDR'." DECIMALS 0.
  PERFORM f_write_text USING c1 w29 l_text ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c2 = w30 - 5.
  WRITE AT c1(c2)  l_mampu INPUT ON NO-GAP. c1 = c1 + c2.

  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w31 wa_form2-top_hitung ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c2 = w32 - 5.
  WRITE AT c1(c2)  l_reason INPUT ON NO-GAP. c1 = c1 + c2.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w33 ' ' ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w34 ' ' ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.

  CONDENSE wa_form2-status.
  CONDENSE wa_form2-remark_top.
  CONDENSE wa_form2-remark_cl.
  CONDENSE wa_form2-remark_top.
  CONCATENATE   wa_form2-status  '->'  wa_form2-remark
               INTO l_reason SEPARATED BY space.
  PERFORM f_write_text USING c1 w3  l_reason  ' '.
  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  PERFORM f_write_text USING c1 w35 wa_form2-kvgr3 ' '.
*  PERFORM f_write_text USING c1 1 sy-vline 'C'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
ENDFORM.                    " f_write_detail2
*&---------------------------------------------------------------------*
*&      Form  f_write_footer_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_footer_layout .
  WRITE: / sy-vline, 'Lampiran'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
  WRITE: / sy-vline, '1. Copy PO/Surat Pesanan.                 [   ]  4. Bukti Sejarah Pembayaran 12 Bulan.                   [   ]'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
  WRITE: / sy-vline, '2. Rekomendasi dari Principal             [   ]  5. Trend Sales Tahun Lalu dan Tahun Ini dilampirkan     [   ]'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
  WRITE: / sy-vline, '3. Daftar Faktur Terbuka dilampirkan      [   ]  6. Formulir Usulan Kenaikan CL dg Nilai > 50 juta       [   ]'.
  c1 = c4.
  PERFORM f_write_garis USING c1.
  WRITE: / sy-uline(c4).

*  WRITE: / sy-vline.
*  c1 = c4.
*  PERFORM f_write_garis USING c1.
  WRITE: / sy-vline, 'Otorisasi Cabang untuk Credit Limit Insidentil'.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 'Maksimal Jumlah Kenaikan CL sebesar Rp 50 Juta' 'C'.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 'BM & BOM/BOS' 'C'.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w36 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline, 'Otorisasi Kantor Pusat untuk Credit Limit Insidentil'.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_text USING c1 w36 'Tanggal, ....................................... ' ' '.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  c2 = w36 - 1.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b 'Maksimal Jumlah Kenaikan CL :' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Maksimal Jumlah Kenaikan CL :' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Maksimal Jumlah Kenaikan CL :' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  c2 = w36 - 1.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 'Permohonan diajukan oleh,' 'C'.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b '150% atau Nilai Rupiah' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b '175% atau Nilai Rupiah' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b '200% atau Nilai Rupiah' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Maksimal Rupiah' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Tanpa Batas' 'C'.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = w36 - 1.
  PERFORM f_write_text USING c1 c2 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b 'Mana Yang Lebih Kecil' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Mana Yang Lebih Kecil' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Mana Yang Lebih Kecil' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline ' '.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 ' ' ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b 'SOH/BFC' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'SSOH & GMFC/GMFA' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'SD/OD & FD' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'MDSO/VPD & FD' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'PD' 'C'.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 sy-uline ' '.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b 'Rp 100 juta' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Rp 350 juta' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Rp 750 juta' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b 'Rp 1 Milyard' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b ' ' 'C'.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 'BM / KCP' 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 'BSM / CSSPV / Sr SPV' 'C'.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.

  WRITE: / sy-vline. c1 = 2.
  PERFORM f_write_text USING c1 w17b sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 w17b sy-uline 'C'.
  PERFORM f_write_garis USING c1.

*  c1 = 2 + w35 + w25 + w26 + w27 + w28 + w29 + w30 + w23.
  c1 = 2 + w17b + w17b + w17b + w17b + w17b + w3.
  PERFORM f_write_garis USING c1.
  c2 = ( w36 / 2 ) - 1.
  PERFORM f_write_text USING c1 c2 sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  PERFORM f_write_text USING c1 c2 sy-uline 'C'.
  PERFORM f_write_garis USING c1.
  c1 = c4.
  PERFORM f_write_garis USING c1.
ENDFORM.                    " f_write_footer_layout

*&---------------------------------------------------------------------*
*&      Form  f_write_garis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C1  text
*----------------------------------------------------------------------*
FORM f_write_garis USING    p_c TYPE i.
  WRITE AT p_c(1)   sy-vline NO-GAP.
  p_c = p_c + 1.

ENDFORM.                    " f_write_garis
*&---------------------------------------------------------------------*
*&      Form  f_data_6_bulan
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_data_6_bulan .
  DATA: l_gjahr1 LIKE knc1-gjahr,
        l_gjahr2 LIKE knc1-gjahr,
        l_spmon1 LIKE s603-spmon,
        l_spmon2 LIKE s603-spmon.

  l_gjahr1 = sy-datum(4) - 1.
  l_gjahr2 = sy-datum(4).

  IF i_kunnr IS INITIAL.
    EXIT.
  ENDIF.
  SELECT * INTO TABLE i_knc1 FROM knc1
      FOR ALL ENTRIES IN i_kunnr
      WHERE kunnr = i_kunnr-kunnr AND
            bukrs = so_vkorg AND
            ( gjahr = l_gjahr1 OR  gjahr = l_gjahr2 ).


  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = 6
    IMPORTING
      newdate    = l_date.

  l_spmon1 = sy-datum(6).
  l_spmon2 = l_date(6).
  IF gv_auart(3) = 'ZT7' OR gv_auart(3) = 'ZA7'.

    LOOP AT gt_zsmapping_soff INTO gs_zsmapping_soff.
      gv_vkbur = gs_zsmapping_soff-vkbur2.
    ENDLOOP.

  ENDIF.
****  SELECT spmon vkbur pkunwe SUM( umkzwi1 ) SUM( gukzwi1 ) INTO TABLE i_s603
  SELECT spmon pkunwe SUM( umkzwi1 ) SUM( gukzwi1 ) INTO TABLE i_s603
       FROM s603
            WHERE pkunwe IN so_knkli AND
                  ( vkbur = gv_vkbur OR vkbur = so_vkbur ) AND
                  vrsio = '000' AND
                  spmon >= l_spmon2 AND spmon <= l_spmon1
                  GROUP BY spmon pkunwe.
***                  GROUP BY spmon vkbur pkunwe.

ENDFORM.                    " f_data_6_bulan
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form .
  SORT i_form1 BY temp_no znou.
  SORT i_form2 BY temp_no znou.
  LOOP AT i_form1 INTO wa_form1.
    AT NEW temp_no.
      c4 =  w21 + w22 + w23 + ( w24 * 15 ) + 19.
      NEW-PAGE LINE-SIZE  c4.
      PERFORM f_write_header.
      PERFORM f_write_collumn_header1.
    ENDAT.
    PERFORM f_write_detail1.
    PERFORM f_write_collumn_header11.
    PERFORM f_write_detail11.
    AT END OF temp_no.
      PERFORM f_write_collumn_header2.
      LOOP AT i_form2 INTO wa_form2 WHERE temp_no = wa_form1-temp_no.
        PERFORM f_write_detail2.
        CLEAR: wa_itab.
      ENDLOOP.
      WRITE: / sy-uline.
      PERFORM f_write_footer_layout.
      WRITE: / sy-uline.
      SKIP 2.
    ENDAT.
  ENDLOOP.
*        WRITE: / sy-uline.

ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_isi_data_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_isi_data_form .
  REFRESH: i_itab1.
  CLEAR: i_itab1, wa_itab.
  MOVE 'Permohonan Otorisasi Toleransi Over TOP Internal & Credit Limit Insidentil' TO v_title1.
  CONCATENATE 'Cabang : ' so_vkbur '-' va_gtext INTO v_title2.
  v_repid = 'Form Over TOP & CL Insidentil'.
  v_current_page = 1.
  NEW-PAGE.
  CLEAR: va_length.
  va_ctr = 1.
  LOOP AT i_vbeln INTO wa_vbeln.
    READ TABLE i_itab INTO wa_itab
         WITH KEY vbeln = wa_vbeln-vbeln.
    IF sy-subrc EQ 0.
      APPEND wa_itab TO i_itab1.
    ENDIF.
  ENDLOOP.
  SORT i_itab1 BY vkbur remark kunnr.
  CLEAR: va_ctr, va_length.
  LOOP AT i_itab1 INTO wa_itab.
    ON CHANGE OF wa_itab-remark.
      ADD 1 TO va_ctr.
      sw = 0.
      va_length = 0.
    ENDON.
    MOVE-CORRESPONDING wa_itab TO wa_form1.
    MOVE-CORRESPONDING wa_itab TO wa_form2.
    ADD 1 TO va_length.
    IF va_length = 6.
      va_length  = 1.
      IF sw = 1.
        ADD 1 TO va_ctr.
      ENDIF.
    ENDIF.
    wa_form1-znou = va_length.
    wa_form2-znou = va_length.
    wa_form1-temp_no = va_ctr.
    wa_form2-temp_no = va_ctr.
    PERFORM f_isi_itab_tmp.
    APPEND wa_form1 TO i_form1.
    APPEND wa_form2 TO i_form2.
    sw = 1.
  ENDLOOP.
*

ENDFORM.                    " f_isi_data_form

*&---------------------------------------------------------------------*
*&      Form  zebra
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zebra USING p_i TYPE i.
*  DATA: i TYPE integer.
  IF wa_itab-postst = 'X'.
    p_i = 5.
  ENDIF.
  IF wa_itab-flag_top EQ 'A'.
    p_i = 7.
  ENDIF.
  IF wa_itab-remark = 'GRS'.
    p_i = 4.
  ENDIF.
  IF wa_itab-remark = 'B2B'. " OR wa_itab-remark = 'GRS'.
    p_i = 6.
  ENDIF.
  IF sw = '0'.
    FORMAT COLOR = p_i INTENSIFIED OFF. sw = '1'.
  ELSE.
    FORMAT COLOR = p_i INTENSIFIED ON. sw = '0'.
  ENDIF.
ENDFORM.                    " zebra
*&---------------------------------------------------------------------*
*&      Form  F_CEK_AUTH_TOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_ITAB_AUTHTOP  text
*----------------------------------------------------------------------*
FORM f_cek_auth_top  CHANGING p_authtop
                              p_dso
                              p_top.
  DATA: lv_usrgroup  LIKE zscl_top-usrgroup,
        lv_usrgroup1 LIKE zscl_top-usrgroup.
  DATA: lv_blart LIKE wa_itab-blart.
  DATA: lt_zscl_top_user_kvg4 TYPE t_zscl_top OCCURS 0.
  DATA: lt_zscl_top_user_kvg3 TYPE t_zscl_top OCCURS 0.
  DATA: lv_sw(1).
  DATA:      li_zscl_top TYPE t_zscl_top OCCURS 0.

  lv_blart = wa_itab-blart.
  IF lv_blart NE 'DA'.
    lv_blart = 'RV'.
  ENDIF.
  CLEAR: p_authtop, wa_zscl_top.
  IF so_vkorg = '8020'.
*** Perubahan tanggal 08 mei 2025
**  atas permintaan IAN dimana untuk cek KVGR4 harus bersama dengan KVGR3
**  jika KVGR4 kosong maka cek di KVGR3 saja
    IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
**    READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
**    BINARY SEARCH.
**    IF sy-subrc EQ 0.
**      IF wa_kunnr-fkart(3) NE 'ZB7'.
**        lv_sw = '1'.
**      ENDIF.
**    ENDIF.

      CLEAR: lv_sw.
      SELECT zurut usrgroup kvgr3 kvgr4 zhari zhextra zdept usrgroup1 usrgroup2
             INTO CORRESPONDING FIELDS OF TABLE li_zscl_top
             FROM zscl_top
      WHERE kvgr3 = wa_itab-kvgr3 AND
            zhari >= wa_itab-top.
      SORT li_zscl_top BY zurut.
      LOOP AT li_zscl_top INTO wa_zscl_top.
        IF wa_zscl_top-zhari >= wa_itab-top.
          IF wa_zscl_top-usrgroup EQ 'PD' OR  wa_zscl_top-usrgroup1 = 'PD'.
            lv_sw = '1'.
            EXIT.
          ENDIF.
        ENDIF.
        EXIT.
      ENDLOOP.
    ENDIF.



    SORT i_zscl_top_user BY kvgr3 kvgr4.
    lt_zscl_top_user_kvg3[] = i_zscl_top_user[].
    DELETE lt_zscl_top_user_kvg3[] WHERE kvgr3 NE wa_itab-kvgr3.
    "    DELETE lt_zscl_top_user_kvg3[] WHERE kvgr4 EQ space.
    SORT lt_zscl_top_user_kvg3 BY kvgr3.
    LOOP AT lt_zscl_top_user_kvg3 INTO wa_zscl_top WHERE blart = lv_blart.
      IF wa_itab-kvgr3 IS NOT INITIAL AND wa_zscl_top-kvgr3 = wa_itab-kvgr3 AND wa_zscl_top-kvgr4 IS INITIAL.
        SORT i_cntrext01 BY kdgrp auart usrgroup.
        READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                        auart = wa_itab-auart
                                        usrgroup = va_usergrp
                                        BINARY SEARCH.
        IF sy-subrc EQ 0.
          wa_zscl_top-zhari = i_cntrext01-zhextra2.
          IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
            READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF wa_kunnr-fkart(3) NE 'ZB7'.
                IF lv_sw = '1'.
                  wa_zscl_top-zhari = 0.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        SORT i_cntrext BY auart.
        READ TABLE i_cntrext WITH KEY auart = wa_itab-auart.
        IF sy-subrc = 0 AND wa_zscl_top-zurut GT '02' AND wa_zscl_top-usrgroup NE 'PD'.
          wa_zscl_top-zhari = i_cntrext-zhextra2.
        ELSE.
*   Change 12/10/2011
          SORT i_cntre BY auart.
          READ TABLE i_cntre WITH KEY auart = wa_itab-auart BINARY SEARCH.
          IF sy-subrc = 0.
            wa_zscl_top-zhari = wa_zscl_top-zhari + wa_zscl_top-zhextra.
          ENDIF.
        ENDIF.
        IF wa_zscl_top-zhari >= p_top. "dso.
          p_authtop = 'X'. "wa_itab-authtop = 'X'.
          EXIT.
        ELSE.
          p_authtop = space. "wa_itab-authtop = space.
        ENDIF.
      ENDIF.
      CLEAR: wa_zscl_top.
    ENDLOOP.
    lt_zscl_top_user_kvg4[] = i_zscl_top_user[].
    DELETE lt_zscl_top_user_kvg4[] WHERE kvgr4 NE wa_itab-kvgr4.
    SORT lt_zscl_top_user_kvg4 BY kvgr3 kvgr4.
    LOOP AT lt_zscl_top_user_kvg4 INTO wa_zscl_top WHERE blart = lv_blart.
      IF wa_itab-kvgr4 IS NOT INITIAL AND wa_zscl_top-kvgr4 = wa_itab-kvgr4.
        SORT i_cntrext01 BY kdgrp auart usrgroup.
        READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                        auart = wa_itab-auart
                                        usrgroup = va_usergrp
                                        BINARY SEARCH.
        IF sy-subrc EQ 0.
          wa_zscl_top-zhari = i_cntrext01-zhextra2.
          IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
            READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF wa_kunnr-fkart(3) NE 'ZB7'.
                IF lv_sw = '1'.
                  wa_zscl_top-zhari = 0.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.


        SORT i_cntrext BY auart.
        READ TABLE i_cntrext WITH KEY auart = wa_itab-auart.
        IF sy-subrc = 0 AND wa_zscl_top-zurut GT '02' AND wa_zscl_top-usrgroup NE 'PD'.
          wa_zscl_top-zhari = i_cntrext-zhextra2.
        ELSE.
*   Change 12/10/2011
          SORT i_cntre BY auart.
          READ TABLE i_cntre WITH KEY auart = wa_itab-auart BINARY SEARCH.
          IF sy-subrc = 0.
            wa_zscl_top-zhari = wa_zscl_top-zhari + wa_zscl_top-zhextra.
          ENDIF.
        ENDIF.
        IF p_dso = p_top.
          wa_zscl_top-zhari = wa_zscl_top-zhextra.
        ENDIF.
        IF wa_zscl_top-zhari >= p_dso.
          p_authtop = 'X'. "wa_itab-authtop = 'X'.
          EXIT.
        ELSE.
          p_authtop = space. "wa_itab-authtop = space.
        ENDIF.
      ENDIF.
      CLEAR: wa_zscl_top.
    ENDLOOP.
    IF p_authtop NE 'X'.
      SORT i_cntrext01 BY kdgrp auart usrgroup.
      READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                      auart = wa_itab-auart
                                      usrgroup = va_usergrp
                                      BINARY SEARCH.
      IF sy-subrc EQ 0.
        wa_zscl_top-zhari = i_cntrext01-zhextra2.
*LOOP AT i_kunnr INTO wa_kunnr WHERE kunnr = wa_itab-knkli
        IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
          READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF wa_kunnr-fkart(3) NE 'ZB7'.
              SELECT SINGLE usrgroup usrgroup1 INTO (lv_usrgroup, lv_usrgroup1) FROM zscl_top
                WHERE kvgr3 = wa_itab-kvgr3 AND
                      zhari >= p_top.
              IF sy-subrc EQ 0.
                IF lv_usrgroup EQ 'PD' OR  lv_usrgroup1 = 'PD'.
                  wa_zscl_top-zhari = 0.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF so_vkorg = '8070'.
    SORT i_zscl_top BY usrgroup auart zdept.
    SORT i_zscl_top BY auart usrgroup usrgroup1 usrgroup2.
    p_authtop = space.
    LOOP AT i_zscl_top WHERE auart = wa_itab-auart.
      IF i_zscl_top-usrgroup = va_usergrp.
        IF i_zscl_top-zhari >= p_top.
          p_authtop = 'X'.
        ENDIF.
      ELSEIF i_zscl_top-usrgroup1 = va_usergrp.
        IF i_zscl_top-zhari >= p_top.
          p_authtop = 'X'.
        ENDIF.
      ELSEIF i_zscl_top-usrgroup2 = va_usergrp.
        IF i_zscl_top-zhari >= p_top.
          p_authtop = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " F_CEK_AUTH_TOP
*&---------------------------------------------------------------------*
*&      Form  F_CEK_REMARK_TOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_ITAB_REMARK_TOP  text
*----------------------------------------------------------------------*
FORM f_cek_remark_top  CHANGING p_remark_top1 p_remark_top2 p_remark_top3 p_remark_top .
  DATA: l_sw(1), lv_sw(1),
        lva_flag_bsm LIKE zscl_top-zdept,
        lva_zhextra  LIKE zscl_backtoback-zhextra.
  DATA: lv_usrgroup  LIKE zscl_top-usrgroup,
        lv_usrgroup1 LIKE zscl_top-usrgroup.
  DATA:      li_zscl_top TYPE t_zscl_top OCCURS 0.
  DATA: lv_blart LIKE wa_itab-blart.
  lv_blart = wa_itab-blart.
  IF lv_blart NE 'DA'.
    lv_blart = 'RV'.
  ENDIF.

  lva_flag_bsm = va_flag_bsm.
  IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
**    READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
**    BINARY SEARCH.
**    IF sy-subrc EQ 0.
**      IF wa_kunnr-fkart(3) NE 'ZB7'.
**        lv_sw = '1'.
**      ENDIF.
**    ENDIF.

    CLEAR: lv_sw.
    SELECT zurut usrgroup kvgr3 kvgr4 zhari zhextra zdept usrgroup1 usrgroup2
           INTO CORRESPONDING FIELDS OF TABLE li_zscl_top
           FROM zscl_top
    WHERE kvgr3 = wa_itab-kvgr3 AND
          zhari >= wa_itab-top.
    SORT li_zscl_top BY zurut.
    LOOP AT li_zscl_top INTO wa_zscl_top.
      IF wa_zscl_top-zhari >= wa_itab-top.
        IF wa_zscl_top-usrgroup EQ 'PD' OR  wa_zscl_top-usrgroup1 = 'PD'.
          lv_sw = '1'.
          EXIT.
        ENDIF.
      ENDIF.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF so_vkorg = '8020'.
    IF wa_itab-flag_top NE 'A' OR
     ( wa_itab-flag_top EQ 'A' AND wa_itab-flagtop = 'X' ).
*  lva_flag_bsm = va_flag_bsm.

      CLEAR: p_remark_top1, p_remark_top2, wa_zscl_top.
      IF wa_itab-kvgr4 NE space.
        l_sw = 0.
        SORT  i_zscl_top4 BY kvgr4 zurut zdept.
        LOOP AT i_zscl_top4 INTO wa_zscl_top WHERE kvgr4 = wa_itab-kvgr4 AND blart = lv_blart. " AND zdept = lva_flag_bsm.

          SORT i_cntrext01 BY kdgrp auart usrgroup.
          READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                          auart = wa_itab-auart
                                          usrgroup = wa_zscl_top-usrgroup
                                          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_zscl_top-zhari = i_cntrext01-zhextra2.
            IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
              READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
              BINARY SEARCH.
              IF sy-subrc EQ 0.
                IF wa_kunnr-fkart(3) NE 'ZB7'.
                  IF lv_sw = '1'.
                    wa_zscl_top-zhari = 0.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            SORT i_cntrext01 BY kdgrp auart usrgroup.
            READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                            auart = wa_itab-auart
                                            usrgroup = wa_zscl_top-usrgroup1
                                            BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_zscl_top-zhari = i_cntrext01-zhextra2.
              IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
                READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
                BINARY SEARCH.
                IF sy-subrc EQ 0.
                  IF wa_kunnr-fkart(3) NE 'ZB7'.
                    IF lv_sw = '1'.
                      wa_zscl_top-zhari = 0.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.


* Change 12/10/2011
          READ TABLE i_cntrext WITH KEY auart = wa_itab-auart.
          IF sy-subrc = 0 AND wa_zscl_top-zurut GT '02' AND wa_zscl_top-usrgroup NE 'PD'.
            wa_zscl_top-zhari = i_cntrext-zhextra2.
          ELSE.
* Change 12/10/2011
            SORT i_cntre BY auart.
            READ TABLE i_cntre WITH KEY auart = wa_itab-auart BINARY SEARCH.
            IF sy-subrc = 0.
              ADD wa_zscl_top-zhextra TO wa_zscl_top-zhari.
            ENDIF.
          ENDIF.
          IF wa_itab-dso = wa_itab-top.
            wa_zscl_top-zhari = wa_zscl_top-zhextra.
          ENDIF.
          IF wa_zscl_top-zhari >= wa_itab-dso.
            p_remark_top1 = wa_zscl_top-usrgroup. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            p_remark_top2 = wa_zscl_top-usrgroup1. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            p_remark_top3 = wa_zscl_top-usrgroup2. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            l_sw = 1.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF l_sw = 0.
          SORT  i_zscl_top3 BY kvgr3 zurut zdept..
          LOOP AT i_zscl_top3 INTO wa_zscl_top WHERE kvgr3 = wa_itab-kvgr3  AND blart = lv_blart. " AND zdept = lva_flag_bsm.

            SORT i_cntrext01 BY kdgrp auart usrgroup.
            READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                            auart = wa_itab-auart
                                            usrgroup = wa_zscl_top-usrgroup
                                            BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_zscl_top-zhari = i_cntrext01-zhextra2.
              IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
                READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
                BINARY SEARCH.
                IF sy-subrc EQ 0.
                  IF wa_kunnr-fkart(3) NE 'ZB7'.
                    IF lv_sw = '1'.
                      wa_zscl_top-zhari = 0.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              SORT i_cntrext01 BY kdgrp auart usrgroup.
              READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                              auart = wa_itab-auart
                                              usrgroup = wa_zscl_top-usrgroup1
                                              BINARY SEARCH.
              IF sy-subrc EQ 0.
                wa_zscl_top-zhari = i_cntrext01-zhextra2.
                IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
                  READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
                  BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    IF wa_kunnr-fkart(3) NE 'ZB7'.
                      IF lv_sw = '1'.
                        wa_zscl_top-zhari = 0.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

* Change 12/10/2011
            READ TABLE i_cntrext WITH KEY auart = wa_itab-auart.
            IF sy-subrc = 0 AND wa_zscl_top-zurut GT '02' AND wa_zscl_top-usrgroup NE 'PD'.
              wa_zscl_top-zhari = i_cntrext-zhextra2.
            ELSE.
* Change 12/10/2011
              SORT i_cntre BY auart.
              READ TABLE i_cntre WITH KEY auart = wa_itab-auart BINARY SEARCH.
              IF sy-subrc = 0.
                ADD wa_zscl_top-zhextra TO wa_zscl_top-zhari.
              ENDIF.
            ENDIF.
            IF wa_zscl_top-zhari >= wa_itab-dso.
              p_remark_top1 = wa_zscl_top-usrgroup. "wa_itab-remark_top = wa_zscl_top-usrgroup.
              p_remark_top2 = wa_zscl_top-usrgroup1. "wa_itab-remark_top = wa_zscl_top-usrgroup.
              p_remark_top3 = wa_zscl_top-usrgroup2. "wa_itab-remark_top = wa_zscl_top-usrgroup.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ELSE.
        SORT  i_zscl_top3 BY kvgr3 zurut zdept..
        LOOP AT i_zscl_top3 INTO wa_zscl_top WHERE kvgr3 = wa_itab-kvgr3  AND blart = lv_blart. " AND zdept = lva_flag_bsm.
* Change 12/10/2011
          READ TABLE i_cntrext WITH KEY auart = wa_itab-auart.
          IF sy-subrc = 0 AND wa_zscl_top-zurut GT '02' AND wa_zscl_top-usrgroup NE 'PD'.
            wa_zscl_top-zhari = i_cntrext-zhextra2.
          ELSE.
* Change 12/10/2011
            SORT i_cntre BY auart.
            READ TABLE i_cntre WITH KEY auart = wa_itab-auart BINARY SEARCH.
            IF sy-subrc = 0.
              ADD wa_zscl_top-zhextra TO wa_zscl_top-zhari.
            ENDIF.
          ENDIF.
          SORT i_cntrext01 BY kdgrp auart usrgroup.
          READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                          auart = wa_itab-auart
                                          usrgroup = wa_zscl_top-usrgroup
                                          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_zscl_top-zhari = i_cntrext01-zhextra2.
            IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
              READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
              BINARY SEARCH.
              IF sy-subrc EQ 0.
                IF wa_kunnr-fkart(3) NE 'ZB7'.
                  IF lv_sw = '1'.
                    wa_zscl_top-zhari = 0.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            SORT i_cntrext01 BY kdgrp auart usrgroup.
            READ TABLE i_cntrext01 WITH KEY kdgrp = wa_itab-kdgrp
                                            auart = wa_itab-auart
                                            usrgroup = wa_zscl_top-usrgroup1
                                            BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_zscl_top-zhari = i_cntrext01-zhextra2.
              IF wa_itab-auart(3) = 'ZT7' OR wa_itab-auart(3) = 'ZA7'.
*{   REPLACE        P01K910258                                        1
*\                READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
*\                BINARY SEARCH.
                "Start SOH: Shell SCI Adjustment 20240221 KS
                SORT i_kunnr BY kunnr.
                READ TABLE i_kunnr INTO wa_kunnr WITH KEY kunnr = wa_itab-knkli
                BINARY SEARCH.
                "End SOH: Shell SCI Adjustment 20240221 KS
*}   REPLACE
                IF sy-subrc EQ 0.
                  IF wa_kunnr-fkart(3) NE 'ZB7'.
                    IF lv_sw = '1'.
                      wa_zscl_top-zhari = 0.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          IF wa_zscl_top-zhari >= wa_itab-top.
            p_remark_top1 = wa_zscl_top-usrgroup. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            p_remark_top2 = wa_zscl_top-usrgroup1. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            p_remark_top3 = wa_zscl_top-usrgroup2. "wa_itab-remark_top = wa_zscl_top-usrgroup.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF wa_itab-remark_top1 IS INITIAL.
        p_remark_top1 = 'PD'. "wa_itab-remark_top = 'PD'.
      ENDIF.
      IF wa_itab-remark_top2 IS INITIAL .
        p_remark_top2 = 'PD'. "wa_itab-remark_top = 'PD'.
      ENDIF.
*    IF p_remark_top = 'PD'.
      IF  wa_itab-backtoback = 'X'.
        CLEAR: lva_zhextra.
        CLEAR: p_remark_top1, p_remark_top2, p_remark_top3.
        IF wa_itab-auart = 'ZT9D' AND wa_itab-kdgrp = '03'.
          SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 zurut usrgroup zhextra.
          LOOP AT i_zscl_backtoback WHERE kkber = so_kkber AND auart = wa_itab-auart AND kdgrp = wa_itab-kdgrp
                                      AND kvgr3 = wa_itab-kvgr3.
            IF i_zscl_backtoback-zhextra >= wa_itab-top.
              l_sw = 1.
              p_remark_top1 = i_zscl_backtoback-usrgroup.
              p_remark_top2 = i_zscl_backtoback-usrgroup1.
              p_remark_top3 = i_zscl_backtoback-usrgroup2.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE.
          l_sw = 0.
          SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 zurut usrgroup zhextra.
          LOOP AT i_zscl_backtoback WHERE kkber = so_kkber AND auart = wa_itab-auart AND kdgrp = wa_itab-kdgrp
                                      AND kvgr3 = wa_itab-kvgr3.
            IF i_zscl_backtoback-zhextra >= wa_itab-top.
              l_sw = 1.
              p_remark_top1 = i_zscl_backtoback-usrgroup.
              p_remark_top2 = i_zscl_backtoback-usrgroup1.
              p_remark_top3 = i_zscl_backtoback-usrgroup2.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF l_sw = 0.
            SORT i_zscl_backtoback BY kkber auart kdgrp zurut usrgroup zhextra.
            LOOP AT i_zscl_backtoback WHERE kkber = so_kkber AND auart = wa_itab-auart AND kdgrp = wa_itab-kdgrp
                                        AND kvgr3 = space.
              IF i_zscl_backtoback-zhextra >= wa_itab-top.
                p_remark_top1 = i_zscl_backtoback-usrgroup.
                p_remark_top2 = i_zscl_backtoback-usrgroup1.
                p_remark_top3 = i_zscl_backtoback-usrgroup2.
                l_sw = 1.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
*    ENDIF.
    ENDIF.
  ENDIF.
  IF so_vkorg = '8070'.
    SORT  i_zscl_top BY auart zurut zdept.
    LOOP AT i_zscl_top WHERE auart = wa_itab-auart. " AND zdept = va_flag_bsm.
      IF i_zscl_top-zhari >= wa_itab-top.
        p_remark_top1 = i_zscl_top-usrgroup.
        p_remark_top2 = i_zscl_top-usrgroup1.
        p_remark_top3 = i_zscl_top-usrgroup2.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF wa_itab-remark_top1 IS INITIAL AND wa_itab-remark_top1 IS INITIAL AND wa_itab-remark_top3 IS INITIAL..
      p_remark_top1 = 'PD'.
      p_remark_top2 = 'PD'.
      p_remark_top3 = 'PD'.
    ENDIF.
  ENDIF.

*** Perlu dicari top1 dan top2  (5 juni 2017)

  IF p_remark_top2 IS INITIAL.
    p_remark_top =  p_remark_top1.
  ELSE.
    CONDENSE: p_remark_top1, p_remark_top2, p_remark_top3.
    IF p_remark_top3 IS INITIAL.
      CONCATENATE p_remark_top1 '&' p_remark_top2  INTO p_remark_top.
    ELSE.
      CONCATENATE p_remark_top1 '&' p_remark_top2 '&' p_remark_top3 INTO p_remark_top.
    ENDIF.
  ENDIF.
  IF p_remark_top1 EQ p_remark_top2 AND p_remark_top2 EQ p_remark_top3.
    p_remark_top =  p_remark_top1.
  ENDIF.
  IF p_remark_top IS INITIAL.
    IF wa_itab-backtoback = 'X'.
      IF wa_itab-auart(3) = 'ZT7'. " OR wa_itab-auart = 'ZT7B'.
        p_remark_top = 'ER'.
      ELSE.
        p_remark_top = 'B2B'.
      ENDIF.
      p_remark_top1 = p_remark_top2 = p_remark_top3 = p_remark_top.
    ELSE.
      p_remark_top = 'PD'.
      p_remark_top1 = p_remark_top2 = p_remark_top3 = p_remark_top.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CEK_REMARK_TOP
*&---------------------------------------------------------------------*
*&      Form  F_CEK_REMARK_CL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_ITAB_REMARK_CL  text
*----------------------------------------------------------------------*
FORM f_cek_remark_cl  CHANGING p_remark_cl.
  DATA:         l_value  TYPE wertv10.
  DATA:        lt_zscl_kredit      TYPE t_zscl_kredit OCCURS 0.

  CLEAR: p_remark_cl.
  lt_zscl_kredit[] = i_zscl_kredit[].
***  IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***    LOOP AT i_zscl_kredit INTO wa_zscl_kredit.
***      IF wa_zscl_kredit-usrgroup = 'MDDD' OR wa_zscl_kredit-usrgroup = 'VPD' OR wa_zscl_kredit-usrgroup = 'CFO'.
***        wa_zscl_kredit-zpercentage = 9999.
***        wa_zscl_kredit-zvalue = 99999999.
***        MODIFY i_zscl_kredit FROM wa_zscl_kredit TRANSPORTING zpercentage zvalue.
***      ENDIF.
***      IF wa_zscl_kredit-usrgroup2 = 'MDDD' OR wa_zscl_kredit-usrgroup2 = 'VPD' OR wa_zscl_kredit-usrgroup2 = 'CFO'.
***        wa_zscl_kredit-zpercentage = 9999.
***        wa_zscl_kredit-zvalue = 99999999.
***        MODIFY i_zscl_kredit FROM wa_zscl_kredit TRANSPORTING zpercentage zvalue.
***      ENDIF.
***      IF wa_zscl_kredit-usrgroup3 = 'MDDD' OR wa_zscl_kredit-usrgroup3 = 'VPD' OR wa_zscl_kredit-usrgroup3 = 'CFO'.
***        wa_zscl_kredit-zpercentage = 9999.
***        wa_zscl_kredit-zvalue = 99999999.
***        MODIFY i_zscl_kredit FROM wa_zscl_kredit TRANSPORTING zpercentage zvalue.
***      ENDIF.
***    ENDLOOP.
***  ENDIF.
  SORT i_zscl_kredit BY zrange.
  LOOP AT i_zscl_kredit INTO wa_zscl_kredit.
    l_value = wa_zscl_kredit-zvalue * 100.
    IF wa_zscl_kredit-zpercentage > 999.
      IF l_value >= wa_itab-over_credit.
        CLEAR: wa_itab-remark_cl.
        wa_itab-remark_cl1 = wa_zscl_kredit-usrgroup.
        wa_itab-remark_cl2 = wa_zscl_kredit-usrgroup2.
        wa_itab-remark_cl3 = wa_zscl_kredit-usrgroup3.
        EXIT.
      ENDIF.
    ELSE.
      IF  l_value >= wa_itab-over_credit AND wa_zscl_kredit-zpercentage >= wa_itab-persen.
        CLEAR: wa_itab-remark_cl.
        wa_itab-remark_cl1 = wa_zscl_kredit-usrgroup.
        wa_itab-remark_cl2 = wa_zscl_kredit-usrgroup2.
        wa_itab-remark_cl3 = wa_zscl_kredit-usrgroup3.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  i_zscl_kredit[] = lt_zscl_kredit[].
  CONDENSE wa_itab-remark_cl1.
  CONDENSE wa_itab-remark_cl2.
  CONDENSE wa_itab-remark_cl3.

  IF wa_itab-remark_cl1 IS INITIAL AND wa_itab-remark_cl2 IS INITIAL. " AND wa_itab-remark_cl3 IS INITIAL .
    p_remark_cl = 'PD'.
    wa_itab-remark_cl1 = wa_itab-remark_cl2 = p_remark_cl.
***    IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***      wa_itab-remark_cl1 = 'MDDD'.
***      IF va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
***        wa_itab-remark_cl2 = va_usergrp.
***      ENDIF.
***      "      wa_itab-remark_cl2 = 'VPD'.
***      p_remark_cl = 'MDDD & VPD'.
***    ENDIF.
  ELSE.
    IF wa_itab-remark_cl3 IS NOT INITIAL.
      CONCATENATE   wa_itab-remark_cl1 wa_itab-remark_cl2 wa_itab-remark_cl3 INTO p_remark_cl SEPARATED BY '&'.
    ELSE.
      IF wa_itab-remark_cl1 = 'PD'.
***        IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***          wa_itab-remark_cl1 = 'MDDD'.
***          IF va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
***            wa_itab-remark_cl2 = va_usergrp.
***          ENDIF.
***          "          p_remark_cl = 'MDDD & VPD'.
***        ENDIF.
      ENDIF.
      CONCATENATE   wa_itab-remark_cl1 wa_itab-remark_cl2  INTO p_remark_cl SEPARATED BY '&'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CEK_REMARK_CL
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_8020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_8020 .
  DATA:        l_sw, n_top TYPE p, n_top1 TYPE p,
  l_top(7),
  l_top1(7).
  DATA: lt_bsidzd TYPE t_bsid OCCURS 0 WITH HEADER LINE.

  i_zscl_top4[] = i_zscl_top3[].

  DELETE i_zscl_top3 WHERE kvgr4 NE space.
  DELETE i_zscl_top4 WHERE kvgr4 EQ space.

  SELECT * FROM zscr_control
    INTO CORRESPONDING FIELDS OF TABLE i_cntrext
    WHERE zhextra2 NE 0
      AND kkber    EQ so_kkber.

  SELECT * FROM zscr_control01
    INTO CORRESPONDING FIELDS OF TABLE i_cntrext01
    WHERE zhextra2 NE 0
      AND kkber    EQ so_kkber.

*{   REPLACE        P01K910258                                        1
*\  SELECT * FROM zscr_control
*\    INTO CORRESPONDING FIELDS OF TABLE i_cntr
*\    WHERE stat1 NE space
*\      AND kkber    EQ so_kkber.
  "Start SOH: Shell SCI Adjustment 20240222 RZL
  SELECT * FROM zscr_control
    INTO CORRESPONDING FIELDS OF TABLE i_cntr
    WHERE stat1 NE space
      AND kkber    EQ so_kkber ORDER BY PRIMARY KEY.
  "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
  i_cntre[] = i_cntr[].

  DELETE i_cntre WHERE status NE 'A'.
  DELETE i_cntr WHERE status EQ ' '.

*** Tambahan Checkin untuk Proses Askes Req By wawan & MKO (24/07/2006)
  i_cntrask[] = i_cntr[].
  DELETE ADJACENT DUPLICATES FROM i_cntrask COMPARING fkart.

  REFRESH:  i_itab2.
  CLEAR: i_itab2.

  APPEND LINES OF i_itab TO i_itab2.
*{   INSERT         P01K910258                                        2
  "Start SOH: Shell SCI Adjustment 20240222 RZL
  SORT i_itab2 BY knkli.
  "End SOH: Shell SCI Adjustment 20240222 RZL
*}   INSERT
  DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING knkli.
  LOOP AT i_itab2 INTO wa_itab2.
    r_knkli-sign   = 'I'.
    r_knkli-option = 'EQ'.
    r_knkli-low    = wa_itab2-knkli.
    r_knkli-high   = wa_itab2-knkli.
    APPEND r_knkli.
    i_kdgrp-kdgrp = wa_itab2-kdgrp.
    APPEND i_kdgrp.
    CLEAR: wa_itab2.
  ENDLOOP.

  SELECT bsid~bukrs kunnr blart bsid~belnr zfbdt zbd1t umskz bstat fkart budat
     INTO CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid INNER JOIN vbrk ON bsid~belnr = vbrk~vbeln
    WHERE bsid~bukrs EQ so_vkorg
      AND bsid~kunnr IN r_knkli
      AND umskz EQ ''
      AND bstat EQ ''
      AND shkzg EQ 'S'
      AND blart IN ('RV','ZA')
      ORDER BY bsid~bukrs kunnr.

  SELECT bsid~bukrs kunnr blart bsid~belnr zfbdt zbd1t umskz bstat fkart budat
     APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid INNER JOIN vbrk ON bsid~zuonr = vbrk~zuonr
    WHERE bsid~bukrs EQ so_vkorg
      AND bsid~kunnr IN r_knkli
      AND umskz EQ ''
      AND bstat EQ ''
      AND shkzg EQ 'S'
*      AND blart IN ('DR','DZ')
      AND blart EQ 'DR'
      ORDER BY bsid~bukrs kunnr.
** End revisi by Budi req. by ZUL 21/08/2009

  SELECT bukrs kunnr blart bsid~belnr zfbdt zbd1t umskz bstat budat
     APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid
    WHERE bsid~bukrs EQ so_vkorg AND
          bsid~kunnr IN r_knkli  AND
          umskz EQ 'V'           AND
          bstat EQ ''            AND
          shkzg EQ 'S'           AND
          blart EQ 'DA'
      ORDER BY bsid~bukrs kunnr.

  SELECT SINGLE werks INTO r_vkbur-low FROM zplbc
    WHERE bukrs = so_vkorg  AND
          werks = so_vkbur  AND
          zs01live = 'X'.
  IF sy-subrc = 0.
    r_vkbur-sign = 'I'.
    r_vkbur-option = 'EQ'.
    APPEND r_vkbur.
  ENDIF.
  IF r_vkbur[] IS NOT INITIAL.
    SELECT bsid~bukrs bsid~kunnr blart bsid~belnr zfbdt zbd1t umskz bstat fkart bsid~budat
       APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
      FROM bsid INNER JOIN zsl_hsales ON bsid~zuonr = zsl_hsales~vbeln
      WHERE bsid~bukrs EQ so_vkorg
        AND bsid~kunnr IN r_knkli
        AND umskz EQ ''
        AND bstat EQ ''
        AND zsl_hsales~vkorg = so_vkorg
        AND zsl_hsales~vkbur IN r_vkbur
        AND shkzg EQ 'S'
        AND blart IN ('RV','DR','ZA')
        ORDER BY bsid~bukrs bsid~kunnr.
  ENDIF.

  LOOP AT i_bsid INTO wa_bsid.
    CLEAR: i_cntr.
    SORT i_cntr BY fkart.
    READ TABLE i_cntr WITH KEY fkart = wa_bsid-fkart
    BINARY SEARCH.
    wa_bsid-stat1 = i_cntr-stat1.
*    IF wa_bsid-blart = 'DA'.
*      wa_bsid-top = sy-datum - wa_bsid-budat.
*    ELSE.
    l_date =  wa_bsid-zfbdt + wa_bsid-zbd1t.
    wa_bsid-top = sy-datum - l_date.
*    ENDIF.
    MODIFY i_bsid FROM wa_bsid TRANSPORTING stat1 top.
  ENDLOOP.
*  DELETE i_bsid WHERE top < 0.
  DELETE i_bsid WHERE top <= 0.
  l_sw = '0'.
  CLEAR: wa_kunnr, wa_bsid, l_top, l_top1, l_date.
  SORT i_bsid BY bukrs kunnr stat1 blart.
  LOOP AT i_bsid INTO wa_bsid.
    ON CHANGE OF wa_bsid-bukrs OR
                 wa_bsid-kunnr OR
                 wa_bsid-stat1 OR
                 wa_bsid-blart.
      IF l_sw = '0'.
        l_sw = '1'.
      ELSE.
        APPEND wa_kunnr TO i_kunnr.
        CLEAR: wa_kunnr, l_top1, l_top, n_top, n_top1.
      ENDIF.
    ENDON.
    l_sw = '1'.
    wa_kunnr-fkart = wa_bsid-fkart.
    wa_kunnr-kunnr = wa_bsid-kunnr.
    wa_kunnr-stat1 = wa_bsid-stat1.
    wa_kunnr-blart = wa_bsid-blart.
    l_date =  wa_bsid-zfbdt + wa_bsid-zbd1t.
    l_top1 = sy-datum - l_date.
    n_top1 = wa_bsid-top.
    IF n_top < n_top1.
      wa_kunnr-top = l_top1.
      n_top = l_top1.
      wa_kunnr-n_top = n_top.
      wa_kunnr-zbd1t = wa_bsid-zbd1t.
      wa_kunnr-blart  = wa_bsid-blart.
    ENDIF.
    IF wa_bsid-fkart IN r_fkart_askes.
      wa_kunnr-flag_top  = 'A'.
    ENDIF.
    wa_kunnr-l_top = wa_kunnr-top + wa_kunnr-zbd1t.
  ENDLOOP.
  IF l_sw = '0'.
  ELSE.
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_kunnr, n_top, n_top1.
  ENDIF.

  DELETE i_kunnr WHERE n_top < 0.
  ii_kunnr[] =  i_kunnr[].
  SORT ii_kunnr BY kunnr blart.
  DELETE ii_kunnr WHERE blart NE 'DA'.
  SORT ii_kunnr BY kunnr blart.
  DELETE ADJACENT DUPLICATES FROM ii_kunnr COMPARING kunnr blart.
  LOOP AT ii_kunnr INTO wa_kunnr.
    DELETE i_kunnr WHERE blart NE 'DA' AND kunnr = wa_kunnr-kunnr.
  ENDLOOP.
  REFRESH: i_zsbankgrs .
  CLEAR: i_zsbankgrs, wa_zsbankgrs.
  SELECT a~kunnr a~kdgrp a~zbgctr a~kvgr4 a~waers a~wrbtr a~status
          a~valid_to a~valid_fr
          INTO CORRESPONDING FIELDS OF TABLE i_zsbankgrs
          FROM zsbankgrs AS a
        WHERE a~kunnr IN r_knkli.

  SORT i_zsbankgrs BY kunnr valid_to valid_fr.
  DELETE i_zsbankgrs WHERE kunnr EQ space.
  SORT i_zsbankgrs BY kunnr valid_to valid_fr.
  DELETE ADJACENT DUPLICATES FROM i_zsbankgrs COMPARING kunnr zbgctr valid_to valid_fr.
  DELETE ADJACENT DUPLICATES FROM i_kdgrp COMPARING kdgrp.

  REFRESH: i_zsbankgrp .
  CLEAR: i_zsbankgrp, wa_zsbankgrs.
  SELECT a~kunnr a~kdgrp a~zbgctr a~kvgr4 a~waers a~wrbtr a~status
          a~valid_to a~valid_fr
          INTO CORRESPONDING FIELDS OF TABLE i_zsbankgrp
          FROM zsbankgrs AS a
          FOR ALL ENTRIES IN i_kdgrp
        WHERE kdgrp = i_kdgrp-kdgrp.

  DELETE i_zsbankgrp WHERE kdgrp EQ space.
  SORT i_zsbankgrp BY kdgrp valid_to valid_fr.
  DELETE ADJACENT DUPLICATES FROM i_zsbankgrp COMPARING kdgrp zbgctr valid_to valid_fr.

ENDFORM.                    " F_GET_DATA_8020
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_8070
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_8070 .
  DATA:        l_sw, n_top TYPE p, n_top1 TYPE p,
  l_top(7),
  l_top1(7).

  REFRESH:  i_itab2.
  CLEAR: i_itab2.

  APPEND LINES OF i_itab TO i_itab2.
*{   INSERT         P01K910258                                        1
  "Start SOH: Shell SCI Adjustment 20240222 RZL
  SORT i_itab2 BY knkli.
  "End SOH: Shell SCI Adjustment 20240222 RZL
*}   INSERT
  DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING knkli.
  LOOP AT i_itab2 INTO wa_itab2.
    r_knkli-sign   = 'I'.
    r_knkli-option = 'EQ'.
    r_knkli-low    = wa_itab2-knkli.
    r_knkli-high   = wa_itab2-knkli.
    APPEND r_knkli.
    i_kdgrp-kdgrp = wa_itab2-kdgrp.
    APPEND i_kdgrp.
    CLEAR: wa_itab2.
  ENDLOOP.


* Revisi SUT untuk TOP & DSO
  SELECT bukrs kunnr blart belnr zfbdt zbd1t umskz bstat
     INTO CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid
    WHERE bukrs EQ so_vkorg
      AND kunnr IN r_knkli
      AND umskz EQ ''
      AND bstat EQ ''
      AND shkzg EQ 'S'
      AND blart IN ('RV','ZA')
      ORDER BY bukrs kunnr.

  SELECT bukrs kunnr blart belnr zfbdt zbd1t umskz bstat
     APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid
    WHERE bukrs EQ so_vkorg
      AND kunnr IN r_knkli
      AND umskz EQ ''
      AND bstat EQ ''
      AND shkzg EQ 'S'
*      AND blart IN ('DR','DZ')
      AND blart EQ 'DR'
      ORDER BY bukrs kunnr.
***

  SELECT bukrs kunnr blart bsid~belnr zfbdt zbd1t umskz bstat
     APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
    FROM bsid
    WHERE bsid~bukrs EQ so_vkorg AND
          bsid~kunnr IN r_knkli  AND
          umskz EQ 'V'           AND
          bstat EQ ''            AND
          shkzg EQ 'S'           AND
          blart EQ 'DA'
      ORDER BY bsid~bukrs kunnr.


  LOOP AT i_bsid INTO wa_bsid.
    l_date =  wa_bsid-zfbdt + wa_bsid-zbd1t.
    wa_bsid-top = sy-datum - l_date.
    MODIFY i_bsid FROM wa_bsid TRANSPORTING stat1 top.
  ENDLOOP.
*  DELETE i_bsid WHERE top < 0.
  DELETE i_bsid WHERE top <= 0.
  l_sw = '0'.
  CLEAR: wa_kunnr, wa_bsid, l_top, l_top1, l_date.
  SORT i_bsid BY bukrs kunnr stat1.
  LOOP AT i_bsid INTO wa_bsid.
    ON CHANGE OF wa_bsid-bukrs OR
                 wa_bsid-kunnr OR
                 wa_bsid-stat1.
      IF l_sw = '0'.
        l_sw = '1'.
      ELSE.
        APPEND wa_kunnr TO i_kunnr.
        CLEAR: wa_kunnr, l_top1, l_top, n_top, n_top1.
      ENDIF.
    ENDON.
    l_sw = '1'.
    wa_kunnr-kunnr = wa_bsid-kunnr.
    wa_kunnr-stat1 = wa_bsid-stat1.
    l_date =  wa_bsid-zfbdt + wa_bsid-zbd1t.
    l_top1 = sy-datum - l_date.
    n_top1 = wa_bsid-top.
    IF n_top < n_top1.
      wa_kunnr-top = l_top1.
      n_top = l_top1.
      wa_kunnr-n_top = n_top.
      wa_kunnr-zbd1t = wa_bsid-zbd1t.
      wa_kunnr-blart  = wa_bsid-blart.
    ENDIF.
    IF wa_bsid-fkart IN r_fkart_askes.
      wa_kunnr-flag_top  = 'A'.
    ENDIF.
  ENDLOOP.
  IF l_sw = '0'.
  ELSE.
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_kunnr, n_top, n_top1.
  ENDIF.
  DELETE i_kunnr WHERE n_top < 0.
ENDFORM.                    " F_GET_DATA_8070
*&---------------------------------------------------------------------*
*&      Form  F_CEK_BACKTOBACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KKBER  text
*      -->P_AUART  text
*      -->P_KVGR4  text
*      -->P_USERGRP  text
*      -->P_SUBRC  text
*----------------------------------------------------------------------*
FORM f_cek_backtoback  USING    p_kkber LIKE zscl_backtoback-kkber
                                p_auart LIKE zscl_backtoback-auart
                                p_kdgrp LIKE zscl_backtoback-kdgrp
                                p_kvgr3 LIKE zscl_backtoback-kvgr3
                                p_usergrp LIKE zscl_backtoback-usrgroup
                      CHANGING  p_zhextra LIKE zscl_backtoback-zhextra
                                p_subrc LIKE sy-subrc.
  DATA: lp_kvgr3(1).
  CLEAR: lp_kvgr3.
  SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3.
  READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                        auart = p_auart
                                        kdgrp = p_kdgrp
                                        kvgr3 = p_kvgr3
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    lp_kvgr3 = 'X'.
  ENDIF.
  IF p_auart = 'ZT9D' AND p_kvgr3 = '03'.
    SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 usrgroup.
    READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                          auart = p_auart
                                          kdgrp = p_kdgrp
                                          kvgr3 = p_kvgr3
                                          usrgroup = p_usergrp
    BINARY SEARCH.
    IF sy-subrc NE 0.
      SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 usrgroup1.
      READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                            auart = p_auart
                                            kdgrp = p_kdgrp
                                            kvgr3 = p_kvgr3
                                            usrgroup1 = p_usergrp
      BINARY SEARCH.
    ENDIF.
  ELSE.
    SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 usrgroup.
    READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                          auart = p_auart
                                          kdgrp = p_kdgrp
                                          kvgr3 = p_kvgr3
                                          usrgroup = p_usergrp
    BINARY SEARCH.
    IF sy-subrc NE 0.
      SORT i_zscl_backtoback BY kkber auart kdgrp kvgr3 usrgroup1.
      READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                            auart = p_auart
                                            kdgrp = p_kdgrp
                                            kvgr3 = p_kvgr3
                                            usrgroup1 = p_usergrp
      BINARY SEARCH.
      IF sy-subrc NE 0 AND lp_kvgr3 = space..
        SORT i_zscl_backtoback BY kkber auart kdgrp usrgroup.
        READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                              auart = p_auart
                                              kdgrp = p_kdgrp
                                              usrgroup = p_usergrp
        BINARY SEARCH.
        IF sy-subrc NE 0 AND lp_kvgr3 = space.
          SORT i_zscl_backtoback BY kkber auart kdgrp usrgroup1.
          READ TABLE i_zscl_backtoback WITH KEY kkber = p_kkber
                                                auart = p_auart
                                                kdgrp = p_kdgrp
                                                usrgroup1 = p_usergrp
          BINARY SEARCH.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  p_subrc = sy-subrc.
  IF sy-subrc EQ 0.
    p_zhextra = i_zscl_backtoback-zhextra.
  ENDIF.
ENDFORM.                    " F_CEK_BACKTOBACK



*&---------------------------------------------------------------------*
*&      Form  f_release_do
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_release_do_2016 .
  DATA: l_sw(1), l_message(200), l_flagcl(1),
        l_kunnr        LIKE wa_itab-kunnr,
        l_status       LIKE wa_itab-status.
  DATA: lt_vbeln TYPE t_vbeln OCCURS 0.
  DATA: lv_authtop(1), l_dept LIKE zsauth-zdept.
  DATA:  ta_zghsd_tabcli2016 TYPE zghsd_tabcli2016 OCCURS 0 WITH HEADER LINE.
  DATA: lv_backtoback(1).

  DATA: lv_subrc TYPE sy-subrc.
  DATA: lva_zpercentage LIKE zscl_kredit-zpercentage.

  lva_zpercentage = va_zpercentage.
  CLEAR: l_dept.
  SORT i_zsauth BY usrgroup.
  READ TABLE i_zsauth WITH KEY   usrgroup =  va_usergrp BINARY SEARCH.
  IF sy-subrc NE 0.
    SELECT SINGLE zdept INTO l_dept FROM zsauth WHERE usrgroup =  va_usergrp.
  ELSE.
    l_dept =  i_zsauth-zdept.
  ENDIF.

  RANGES: lr_knkli FOR zghsd_tabcli2016-knkli.
  REFRESH: lt_vbeln, lr_knkli, ta_zghsd_tabcli2016.
  LOOP AT i_vbeln INTO wa_vbeln.
    READ TABLE i_itab INTO wa_itab
         WITH KEY vbeln = wa_vbeln-vbeln.
    IF sy-subrc EQ 0.
      APPEND wa_itab TO i_itab1.
      lr_knkli-sign = 'I'.
      lr_knkli-low  = wa_itab-knkli.
      lr_knkli-option = 'EQ'.
      APPEND lr_knkli.
    ENDIF.
  ENDLOOP.
  IF lr_knkli IS NOT INITIAL.
    SELECT * INTO TABLE ta_zghsd_tabcli2016
      FROM zghsd_tabcli2016
      WHERE vkorg EQ so_vkorg
       AND  vkbur EQ so_vkbur
*       and  VTWEG
       AND  kkber EQ so_kkber
       AND  knkli IN lr_knkli
       AND  status NE 'X'.
  ENDIF.
  SORT i_itab1 BY kunnr vbeln.
  sw = 0.
  REFRESH: i_vbeln, vbeln.
  CLEAR: i_vbeln, wa_vbeln, vbeln, l_kunnr, l_flagcl.
  CLEAR: l_credit_value, l_cl_hitung, wa_itab.
  LOOP AT i_itab1 INTO wa_itab.
***    IF wa_itab-abrvw = 'CBD' OR wa_itab-abrvw = 'COD' OR wa_itab-abrvw = 'CB' OR wa_itab-abrvw = 'CD'.
***      IF va_usergrp = 'MDDD' OR va_usergrp = 'VPD' OR va_usergrp = 'CFO'.
***        va_zpercentage = 9999.
***      ENDIF.
***    ENDIF.
    ON CHANGE OF wa_itab-kunnr.
      IF sw = 1.
        CLEAR: l_sw.
        IF va_usergrp =  'PD'. " and lv_backtoback ne 'X'.
          LOOP AT i_vbeln INTO wa_vbeln.
            APPEND wa_vbeln TO lt_vbeln.
          ENDLOOP.
        ELSE.
* consider partial released DO in exposure calculation
*          LOOP AT ta_zghsd_tabcli2016 INTO wa_zghsd_tabcli WHERE knkli = l_kunnr AND status NE 'X'.
*            SORT i_vbeln BY vbeln.
*            READ TABLE i_vbeln INTO wa_vbeln WITH KEY vbeln = wa_zghsd_tabcli-vbeln BINARY SEARCH.
*            IF sy-subrc EQ 0.
*              CONTINUE.
*            ENDIF.
*            l_credit_value = l_credit_value + wa_zghsd_tabcli-netwr.
*          ENDLOOP.
          IF l_credit_value < l_cl_hitung.
            IF va_usergrp =  'BM'
               OR va_usergrp =  'BSM'
               OR va_usergrp =  'BOS'
               OR va_usergrp =  'BOM'
               OR va_usergrp =  'KCP'
               OR va_usergrp =  'CSSPV'.
              "OR va_usergrp =  'MDSO'
              "OR va_usergrp =  'FD'.
              LOOP AT i_vbeln INTO wa_vbeln.
                APPEND wa_vbeln TO lt_vbeln.
              ENDLOOP.
            ELSE.
              l_over = l_credit_value - l_current.
              IF l_current NE 0.
                wa_itab-persen  = ( l_over / l_current ) * 100.
              ELSE.
                wa_itab-persen  = l_over.
                IF wa_itab-persen > 999.
                  wa_itab-persen = 999.
                ENDIF.
              ENDIF.
              IF va_zpercentage >= 999.
                LOOP AT i_vbeln INTO wa_vbeln.
                  APPEND wa_vbeln TO lt_vbeln.
                ENDLOOP.
              ELSE.
                IF va_zpercentage >= wa_itab-persen.
                  LOOP AT i_vbeln INTO wa_vbeln.
                    APPEND wa_vbeln TO lt_vbeln.
                  ENDLOOP.
                ELSE.
                  IF l_over =< va_zvalue_high.
                    LOOP AT i_vbeln INTO wa_vbeln.
                      APPEND wa_vbeln TO lt_vbeln.
                    ENDLOOP.
                  ELSE.
                    WRITE wa_itab-persen TO l_text DECIMALS 2.
                    MESSAGE i002(zz) WITH 'Customer - ' l_kunnr ' Over Persen : ' l_text.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            l_over = l_credit_value - l_current.
            WRITE l_over TO l_text DECIMALS 0.
            MESSAGE i002(zz) WITH 'Customer - ' l_kunnr ' Over Value : ' l_text.
          ENDIF.
        ENDIF.
        REFRESH: i_vbeln.
        CLEAR: i_vbeln, wa_vbeln,
               l_credit_value, l_cl_hitung.
      ENDIF.
      l_credit_value = wa_itab-credit_exposure.
    ENDON.
    IF l_credit_value < wa_itab-credit_exposure.
      l_credit_value = wa_itab-credit_exposure.
    ENDIF.
    l_kunnr = wa_itab-kunnr.
    l_current =  wa_itab-cl_current.
    l_credit_value = l_credit_value + wa_itab-netwr.
    l_cl_hitung    =  wa_itab-cl_hitung.
    sw = 1.
    wa_vbeln-vbeln = wa_itab-vbeln.
    l_kunnr = wa_itab-kunnr.
    APPEND wa_vbeln TO i_vbeln.
    IF wa_itab-backtoback = 'X'.
      IF wa_itab-authback = 'X'.
        APPEND wa_vbeln TO lt_vbeln.
      ENDIF.
      lv_backtoback = 'X'.
    ELSE.
      CLEAR: lv_backtoback.
    ENDIF.
    CLEAR: wa_itab.
  ENDLOOP.
  IF sw = 1.
    CLEAR: l_sw.
    IF va_usergrp =  'PD'.
      LOOP AT i_vbeln INTO wa_vbeln.
        APPEND wa_vbeln TO lt_vbeln.
      ENDLOOP.
    ELSE.
* consider partial released DO in exposure calculation
*      LOOP AT ta_zghsd_tabcli2016 INTO wa_zghsd_tabcli WHERE knkli = l_kunnr AND status NE 'X'.
*        SORT i_vbeln BY vbeln.
*        READ TABLE i_vbeln INTO wa_vbeln WITH KEY vbeln = wa_zghsd_tabcli-vbeln BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          CONTINUE.
*        ENDIF.
*        l_credit_value = l_credit_value + wa_zghsd_tabcli-netwr.
*      ENDLOOP.
      IF l_credit_value < l_cl_hitung.
        IF va_usergrp =  'BM'
           OR va_usergrp =  'BSM'
           OR va_usergrp =  'BOS'
           OR va_usergrp =  'BOM'
           OR va_usergrp =  'KCP'
           OR va_usergrp =  'CSSPV'.
          "OR va_usergrp =  'MDSO'
          "OR va_usergrp =  'FD'.
          LOOP AT i_vbeln INTO wa_vbeln.
            APPEND wa_vbeln TO lt_vbeln.
          ENDLOOP.
        ELSE.
          l_over = l_credit_value - l_current.
          IF l_current NE 0.
            wa_itab-persen  = ( l_over / l_current ) * 100.
          ELSE.
            wa_itab-persen  = l_over.
            IF wa_itab-persen > 999.
              wa_itab-persen = 999.
            ENDIF.
          ENDIF.
          IF va_zpercentage >= 999.
            LOOP AT i_vbeln INTO wa_vbeln.
              APPEND wa_vbeln TO lt_vbeln.
            ENDLOOP.
          ELSE.
            IF va_zpercentage >= wa_itab-persen.
              LOOP AT i_vbeln INTO wa_vbeln.
                APPEND wa_vbeln TO lt_vbeln.
              ENDLOOP.
            ELSE.
              IF l_over =< va_zvalue_high.
                LOOP AT i_vbeln INTO wa_vbeln.
                  APPEND wa_vbeln TO lt_vbeln.
                ENDLOOP.
              ELSE.
                WRITE wa_itab-persen TO l_text DECIMALS 2.
                MESSAGE i002(zz) WITH 'Customer - ' l_kunnr ' Over Persen : ' l_text.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        l_over = l_credit_value - l_current.
        WRITE l_over TO l_text DECIMALS 0.
        MESSAGE i002(zz) WITH 'Customer - ' l_kunnr ' Over Value : ' l_text.
      ENDIF.
    ENDIF.
    REFRESH: i_vbeln.
    CLEAR: i_vbeln, wa_vbeln,
           l_credit_value, l_cl_hitung.
  ENDIF.
  DATA: lva_subrc LIKE sy-subrc.

  DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING vbeln.
  LOOP AT lt_vbeln INTO wa_vbeln.
    LOOP AT i_itab1 INTO wa_itab WHERE vbeln = wa_vbeln-vbeln.
      CLEAR: lva_subrc.
      CLEAR:  wa_zghsd_tabcli.
      wa_zghsd_tabcli-flagcl = wa_itab-flagcl.
      wa_zghsd_tabcli-flagtop = wa_itab-flagtop.
      wa_zghsd_tabcli-zflagcl = wa_itab-flagcl.
      wa_zghsd_tabcli-zflagtop = wa_itab-flagtop.
      wa_zghsd_tabcli-zflagback = wa_itab-backtoback.
      wa_zghsd_tabcli-zstatus = wa_itab-status.
      wa_zghsd_tabcli-authcl = wa_itab-authcl.
      wa_zghsd_tabcli-authtop = wa_itab-authtop.
      SELECT SINGLE * INTO wa_zghsd_tabcli FROM zghsd_tabcli2016
           WHERE  vkorg  = wa_itab-vkorg
              AND vkbur  = wa_itab-vkbur
              AND kkber  = wa_itab-kkber
              AND knkli  = wa_itab-knkli
              AND vbeln  = wa_itab-vbeln.
      lva_subrc = sy-subrc.
      IF sy-subrc EQ 0.
*        IF wa_zghsd_tabcli-usergroup1 IS INITIAL.
*          wa_zghsd_tabcli-usergroup1 = va_usergrp.
*          wa_zghsd_tabcli-username1  = sy-uname.
*          wa_zghsd_tabcli-udate1  = sy-datum.
*          wa_zghsd_tabcli-utime1  = sy-uzeit.
*        ELSEIF wa_zghsd_tabcli-usergroup2 IS INITIAL.
*          wa_zghsd_tabcli-usergroup2 = va_usergrp.
*          wa_zghsd_tabcli-username2  = sy-uname.
*          wa_zghsd_tabcli-udate2  = sy-datum.
*          wa_zghsd_tabcli-utime2  = sy-uzeit.
*        ENDIF.
        PERFORM f_enter_usergroup USING va_dept va_usergrp ''.

        wa_zghsd_tabcli-zstatus = wa_itab-status.
        wa_zghsd_tabcli-klimk  = wa_itab-cl_current.
        wa_zghsd_tabcli-waers  = 'IDR'.
        wa_zghsd_tabcli-netwr  = wa_itab-netwr.
        wa_zghsd_tabcli-over_kredit  = wa_itab-over_credit.
        wa_zghsd_tabcli-ztop = wa_itab-top.
        MODIFY zghsd_tabcli2016 FROM wa_zghsd_tabcli.

      ELSE.
        wa_zghsd_tabcli-vkorg  = wa_itab-vkorg.
        wa_zghsd_tabcli-vtweg  = wa_itab-vtweg.
        wa_zghsd_tabcli-vkbur  = wa_itab-vkbur.
        wa_zghsd_tabcli-kkber  = wa_itab-kkber.
        wa_zghsd_tabcli-knkli  = wa_itab-knkli.
        wa_zghsd_tabcli-vbeln  = wa_itab-vbeln.
        wa_zghsd_tabcli-klimk  = wa_itab-cl_current.
        wa_zghsd_tabcli-waers  = 'IDR'.
        wa_zghsd_tabcli-netwr  = wa_itab-netwr.
        wa_zghsd_tabcli-over_kredit  = wa_itab-over_credit.
        wa_zghsd_tabcli-ztop = wa_itab-top.
        IF va_usergrp = wa_itab-remark1.
*          wa_zghsd_tabcli-usergroup1 = va_usergrp.
*          wa_zghsd_tabcli-username1  = sy-uname.
*          wa_zghsd_tabcli-udate1  = sy-datum.
*          wa_zghsd_tabcli-utime1  = sy-uzeit.
          PERFORM f_enter_usergroup USING va_dept va_usergrp ''.
        ENDIF.
        IF va_usergrp = wa_itab-remark2.
*          wa_zghsd_tabcli-usergroup2 = va_usergrp.
*          wa_zghsd_tabcli-username2  = sy-uname.
*          wa_zghsd_tabcli-udate2  = sy-datum.
*          wa_zghsd_tabcli-utime2  = sy-uzeit.
          PERFORM f_enter_usergroup USING va_dept va_usergrp ''.
        ENDIF.
*        IF va_usergrp = wa_itab-remark3.
*          wa_zghsd_tabcli-usergroup2 = va_usergrp.
*          wa_zghsd_tabcli-username2 = sy-uname.
*          wa_zghsd_tabcli-udate2  = sy-datum.
*          wa_zghsd_tabcli-utime2  = sy-uzeit.
*        ENDIF.
        wa_zghsd_tabcli-klimk  = wa_itab-cl_current.
        wa_zghsd_tabcli-waers  = 'IDR'.
        wa_zghsd_tabcli-netwr  = wa_itab-netwr.
        wa_zghsd_tabcli-over_kredit  = wa_itab-over_credit.
        wa_zghsd_tabcli-ztop = wa_itab-top.
        wa_zghsd_tabcli-kvgr3 = wa_itab-kvgr3.
        MODIFY zghsd_tabcli2016 FROM wa_zghsd_tabcli.
        MODIFY zghsd_tabcli2017 FROM wa_zghsd_tabcli.
      ENDIF.

      IF va_usergrp = 'PD'.
*        IF wa_zghsd_tabcli-usergroup1 IS INITIAL.
        wa_zghsd_tabcli-usergroup1 = va_usergrp.
        wa_zghsd_tabcli-username1  = sy-uname.
        wa_zghsd_tabcli-udate1  = sy-datum.
        wa_zghsd_tabcli-utime1  = sy-uzeit.
*        ENDIF.
*        IF wa_zghsd_tabcli-usergroup2 IS INITIAL.
        wa_zghsd_tabcli-usergroup2 = va_usergrp.
        wa_zghsd_tabcli-username2  = sy-uname.
        wa_zghsd_tabcli-udate2  = sy-datum.
        wa_zghsd_tabcli-utime2  = sy-uzeit.
*        ENDIF.
        IF wa_itab-backtoback = 'X'.
          IF wa_itab-authback NE 'X'.
            CLEAR: wa_zghsd_tabcli-usergroup1, wa_zghsd_tabcli-username1, wa_zghsd_tabcli-udate1, wa_zghsd_tabcli-utime1,
                   wa_zghsd_tabcli-usergroup2, wa_zghsd_tabcli-username2, wa_zghsd_tabcli-udate2, wa_zghsd_tabcli-utime2.
          ENDIF.
        ENDIF.
        MODIFY zghsd_tabcli2016 FROM wa_zghsd_tabcli.
      ENDIF.

      IF wa_zghsd_tabcli-usergroup1 IS NOT INITIAL AND
         wa_zghsd_tabcli-usergroup2 IS NOT INITIAL AND
         wa_zghsd_tabcli-zstatus(5) NE 'CLEAR'.
        vbeln-low = wa_vbeln-vbeln.
        vbeln-option = 'EQ'.
        vbeln-sign   = 'I'.
        APPEND vbeln.
        APPEND wa_vbeln TO i_vbeln.
        APPEND wa_zghsd_tabcli TO i_zghsd_tabcli.
        CONCATENATE 'REL :' wa_zghsd_tabcli-usergroup1 wa_zghsd_tabcli-usergroup2
           INTO wa_itab-status SEPARATED BY space.
      ENDIF.
*      ENDIF.

      IF wa_zghsd_tabcli-zstatus(5) = 'CLEAR'.
*        IF wa_zghsd_tabcli-usergroup1 IS INITIAL.
*          wa_zghsd_tabcli-usergroup1 = va_usergrp.
*          wa_zghsd_tabcli-username1  = sy-uname.
*          wa_zghsd_tabcli-udate1  = sy-datum.
*          wa_zghsd_tabcli-utime1  = sy-uzeit.
*        ENDIF.
*        IF wa_zghsd_tabcli-usergroup2 IS INITIAL.
*          wa_zghsd_tabcli-usergroup2 = va_usergrp.
*          wa_zghsd_tabcli-username2  = sy-uname.
*          wa_zghsd_tabcli-udate2  = sy-datum.
*          wa_zghsd_tabcli-utime2  = sy-uzeit.
*        ENDIF.
        PERFORM f_enter_usergroup USING va_dept va_usergrp 'CLEAR'.
        vbeln-low = wa_vbeln-vbeln.
        vbeln-option = 'EQ'.
        vbeln-sign   = 'I'.
        APPEND vbeln.
        APPEND wa_vbeln TO i_vbeln.
        APPEND wa_zghsd_tabcli TO i_zghsd_tabcli.
      ENDIF.

      CONCATENATE wa_itab-status va_usergrp INTO wa_itab-status SEPARATED BY ','.
      CLEAR: wa_itab-mark1.
      MODIFY i_itab1 FROM wa_itab TRANSPORTING status mark1.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM i_vbeln COMPARING ALL FIELDS.
  LOOP AT  i_vbeln INTO wa_vbeln.
    PERFORM f_order_credit_release USING wa_vbeln-vbeln
                                   CHANGING lv_subrc.

*    CALL FUNCTION 'SD_ORDER_CREDIT_RELEASE'
*      EXPORTING
*        vbeln         = wa_vbeln-vbeln
*      EXCEPTIONS
*        error_message = 4.
*    IF sy-subrc EQ 0.
    IF lv_subrc EQ 0.
      LOOP AT i_zghsd_tabcli INTO wa_zghsd_tabcli
              WHERE vbeln = wa_vbeln-vbeln.
        wa_zghsd_tabcli-status = 'X'.
        MODIFY zghsd_tabcli2016 FROM wa_zghsd_tabcli.
        MODIFY zghsd_tabcli2017 FROM wa_zghsd_tabcli.
      ENDLOOP.
    ELSE.
      IF wa_zghsd_tabcli-usergroup1 = va_usergrp.
        CLEAR: wa_zghsd_tabcli-usergroup1, wa_zghsd_tabcli-username1,
        wa_zghsd_tabcli-udate1, wa_zghsd_tabcli-utime1.
      ENDIF.
      IF wa_zghsd_tabcli-usergroup2 = va_usergrp.
        CLEAR: wa_zghsd_tabcli-usergroup2, wa_zghsd_tabcli-username2,
        wa_zghsd_tabcli-udate2, wa_zghsd_tabcli-utime2.
      ENDIF.
      MODIFY zghsd_tabcli2016 FROM wa_zghsd_tabcli.
      MODIFY zghsd_tabcli2017 FROM wa_zghsd_tabcli.
      DELETE i_itab1 WHERE vbeln = wa_vbeln-vbeln.
      MESSAGE i002(zz) WITH 'Locked by another user/Check Listing Exclusion'.
    ENDIF.
  ENDLOOP.

  SORT i_itab1 BY auart vkorg vkbur knkli kkber kunnr vbeln.
  SORT i_itab1 BY auart vkorg vkbur knkli kkber kunnr vbeln.
  LOOP AT i_itab1 INTO wa_itab.
    LOOP AT i_itab INTO wa_itab2 WHERE
                            auart = wa_itab-auart AND
                            vkorg = wa_itab-vkorg AND
                            vkbur = wa_itab-vkbur AND
                            knkli = wa_itab-knkli AND
                            kkber = wa_itab-kkber AND
                            kunnr = wa_itab-kunnr AND
                            vbeln = wa_itab-vbeln.
      IF wa_itab2-status NE wa_itab-status.
        wa_itab2-status = wa_itab-status.
        wa_itab2-postst = 'X'.
      ENDIF.
      IF wa_itab2-mark1 NE wa_itab-mark1.
        wa_itab2-mark1 = wa_itab-mark1.
        wa_itab2-postst = 'X'.
      ENDIF.
      MODIFY i_itab FROM wa_itab2 TRANSPORTING status mark1 postst.
      CLEAR: wa_itab2.
    ENDLOOP.
    CLEAR: wa_itab.
  ENDLOOP.
  REFRESH: i_itab1.

ENDFORM.                    " f_release_do

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table  USING    fu_vbeln
                            fu_dept
                   CHANGING fc_subrc.
  CALL FUNCTION 'ENQUEUE_EZSCL_LOCK'
    EXPORTING
      vbeln          = fu_vbeln
      zdept          = fu_dept
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2.
  fc_subrc = sy-subrc.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table  USING  fu_vbeln
                            fu_dept
                   CHANGING fc_subrc.
  CALL FUNCTION 'DEQUEUE_EZSCL_LOCK'
    EXPORTING
      vbeln          = fu_vbeln
      zdept          = fu_dept
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2.
  fc_subrc = sy-subrc.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ENTER_USERGROUP
*&---------------------------------------------------------------------*
FORM f_enter_usergroup  USING    fu_dept
                                 fu_usergrp
                                 fu_clear.
  IF fu_clear IS INITIAL.
    CASE fu_dept.
      WHEN '1'.
        IF wa_zghsd_tabcli-usergroup1 IS INITIAL.
          wa_zghsd_tabcli-usergroup1 = fu_usergrp.
          wa_zghsd_tabcli-username1  = sy-uname.
          wa_zghsd_tabcli-udate1  = sy-datum.
          wa_zghsd_tabcli-utime1  = sy-uzeit.
        ENDIF.
      WHEN '2'.
        IF wa_zghsd_tabcli-usergroup2 IS INITIAL.
          wa_zghsd_tabcli-usergroup2 = fu_usergrp.
          wa_zghsd_tabcli-username2  = sy-uname.
          wa_zghsd_tabcli-udate2  = sy-datum.
          wa_zghsd_tabcli-utime2  = sy-uzeit.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE fu_dept.
      WHEN '1'.
        wa_zghsd_tabcli-usergroup1 = fu_usergrp.
        wa_zghsd_tabcli-username1  = sy-uname.
        wa_zghsd_tabcli-udate1  = sy-datum.
        wa_zghsd_tabcli-utime1  = sy-uzeit.
      WHEN '2'.
        wa_zghsd_tabcli-usergroup2 = fu_usergrp.
        wa_zghsd_tabcli-username2  = sy-uname.
        wa_zghsd_tabcli-udate2  = sy-datum.
        wa_zghsd_tabcli-utime2  = sy-uzeit.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_ENTER_USERGROUP

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_CREDIT_RELEASE
*&---------------------------------------------------------------------*
FORM f_order_credit_release  USING    fu_vbeln
                             CHANGING fc_subrc.
  DATA : rspar_tab  TYPE TABLE OF rsparams,
         rspar_line LIKE LINE OF rspar_tab.
  DATA : lv_idsub(40).

  CALL FUNCTION 'BUFFER_REFRESH_ALL'.
  CONCATENATE sy-uname 'SUBRC_OCR' INTO lv_idsub.

  FREE MEMORY ID lv_idsub.

  rspar_line-selname = 'PA_VBELN'.
  rspar_line-kind    = 'S'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = fu_vbeln.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

  SUBMIT zsd_ocr WITH SELECTION-TABLE rspar_tab
  AND RETURN.

  IMPORT lv_subrc TO fc_subrc FROM MEMORY ID lv_idsub.
ENDFORM.                    " F_ORDER_CREDIT_RELEASE

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_KVGR3
*&---------------------------------------------------------------------*
FORM f_filter_kvgr3 .
  LOOP AT i_itab INTO wa_itab.
    AUTHORITY-CHECK OBJECT 'ZSKVGR3'
        ID 'KVGR3' FIELD wa_itab-kvgr3.
    IF sy-subrc NE 0.
      DELETE TABLE i_itab FROM wa_itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_FILTER_KVGR3
