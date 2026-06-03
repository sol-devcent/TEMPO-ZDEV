REPORT zs_upload_sales NO STANDARD PAGE HEADING MESSAGE-ID 00
                        LINE-SIZE 170.
TABLES : zsh_b2b, zsd_b2b, zsmat_b2b, zsb2b_errlog, knvv.

INCLUDE zvx_interface_incl.

DATA: BEGIN OF itab OCCURS 0,
           ztext(500),
           index(5), " TYPE i,
           zst_err(1),
           zst_delete(1),
           zstatus(1),
           ebeln LIKE zsh_b2b-ebeln,
      END OF itab.
DATA: BEGIN OF i_b2blog OCCURS 0.
        INCLUDE STRUCTURE   zsb2b_errlog.
DATA:      zstatus(1),
      END OF i_b2blog.
DATA: BEGIN OF itab_h OCCURS 0,
           type(6),
           sup_name(35),
           po_no(9),
           po_date(8),
           exp_date(8),
           sen_name(35),
           sup_code(5),
           kd_unit(1),
           kd_dc(5),
           index(5), " TYPE i,
      END OF itab_h,
      wa_itab_h LIKE itab_h.

DATA: BEGIN OF itab_d OCCURS 0,
          type(6),
          barcode(13),
          qty(5),
          satuan(4),
          harga(8),
          plu(8),
          desc(28),
          bonus1(5),
          bonus2(5),
          total(13),
          po_no(9),
          index(5), " TYPE i,
      END OF itab_d,
      wa_itab_d LIKE itab_d.

DATA: BEGIN OF wa_adrc,
        addrnumber LIKE adrc-addrnumber,
        sort2  LIKE  adrc-sort2,
      END OF wa_adrc.

DATA: BEGIN OF wa_cust,
        adrnr  LIKE  kna1-adrnr,
        kunnr  LIKE  kna1-kunnr,
        vkorg  LIKE  knvv-vkorg,
        vtweg  LIKE  knvv-vtweg,
        spart  LIKE  knvv-spart,
        vkbur  LIKE  knvv-vkbur,
      END OF wa_cust.

DATA: BEGIN OF i_matb2b OCCURS 0.
        INCLUDE STRUCTURE zsmat_b2b.
DATA:   bstme  LIKE  zsuom_b2b-bstme,
        poqty  LIKE  zsuom_b2b-poqty,
        doqty  LIKE  zsuom_b2b-doqty,
        vrkme  LIKE  zsuom_b2b-vrkme,
      END OF i_matb2b.

DATA: BEGIN OF i_zsd_b2b OCCURS 0.
        INCLUDE STRUCTURE zsd_b2b.
DATA:   ebeln  LIKE  zsh_b2b-ebeln,
      END OF i_zsd_b2b.

DATA: i_zsh_b2b LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
*      i_zsd_b2b LIKE zsd_b2b OCCURS 0 WITH HEADER LINE,
*      i_zmap_matnr LIKE zmap_matnr OCCURS 0 WITH HEADER LINE,
      i_sukses LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
      wa_itab LIKE itab,
      wa_itab1 LIKE itab,
      v_delete(1).

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS :
* Customer
  c_cust(10)  TYPE c VALUE '0000000010',
* Paths
  c_interfacein(125)      TYPE c VALUE '\in',
  c_interfaceprocess(125) TYPE c VALUE '\process',
  c_interfacesuccess(125) TYPE c VALUE '\archive',
  c_interfaceerror(125)   TYPE c VALUE '\in',
  c_interfacedelete(125)   TYPE c VALUE '\delete',
  c_logfile(125)          TYPE c VALUE '\log',

  c_interfacein_aix(125)      TYPE c VALUE '/in',
  c_interfaceprocess_aix(125) TYPE c VALUE '/process',
  c_interfacesuccess_aix(125) TYPE c VALUE '/archive',
  c_interfaceerror_aix(125)   TYPE c VALUE '/in',
  c_interfacedelete_aix(125)   TYPE c VALUE '/delete',
  c_logfile_aix(125)          TYPE c VALUE '/log'.

*  c_starttext(20) TYPE c    VALUE 'B2B'.

DATA :  v_interfacein(125) TYPE c,
        v_interfaceprocess(125) TYPE c,
        v_interfacesuccess(125) TYPE c,
        v_interfaceerror(125) TYPE c,
        v_interfacedelete(125) TYPE c,
        v_logfile(125) TYPE c,
        v_file_prefix(60) TYPE c.

DATA:   v_error_msg(125) TYPE c VALUE '',
        v_fileindex TYPE i,
        v_mstring(255),
        v_record TYPE i,l_fileindex TYPE i,
        va_totrecord TYPE i,va_ctr TYPE i,
        va_totproses TYPE i,
        va_toterror  TYPE i,
        va_totdelete  TYPE n,
        c_starttext(20) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK aaa WITH FRAME TITLE text-aaa.
PARAMETERS: p_path(125) DEFAULT '\\tdsdev01\interface\B2B\indomart' LOWER CASE,
            p_start(10),
            p_kvgr4 LIKE zsmat_b2b-kvgr4 OBLIGATORY,
            p_flname LIKE zsb2b_errlog-filename NO-DISPLAY,
            p_delete(1) NO-DISPLAY.
*            p_vkbur LIKE zsh_b2b-vkbur OBLIGATORY,
*            p_vkorg LIKE zsh_b2b-vkorg DEFAULT '8020' NO-DISPLAY.
*SELECT-OPTIONS: s_flname FOR zsb2b_errlog-filename NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK aaa.


INITIALIZATION.
*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    p_path = '/interface/B2B/indomart'.
  ENDIF.

START-OF-SELECTION.
*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    CONCATENATE p_path c_interfacein_aix       INTO v_interfacein.
    CONCATENATE p_path c_interfaceprocess_aix  INTO v_interfaceprocess.
    CONCATENATE p_path c_interfaceerror_aix    INTO v_interfaceerror.
    CONCATENATE p_path c_interfacesuccess_aix  INTO v_interfacesuccess.
    CONCATENATE v_interfacesuccess '/' sy-datum(4) '/' sy-datum+4(2) INTO v_interfacesuccess.
    CONCATENATE p_path c_interfacedelete_aix   INTO v_interfacedelete.
    CONCATENATE v_interfacedelete '/' sy-datum(4) '/' sy-datum+4(2) INTO v_interfacedelete.
    CONCATENATE p_path c_logfile_aix           INTO v_logfile.
    CONCATENATE v_logfile '/' sy-datum(4) '/' sy-datum+4(2) '/idm' INTO v_logfile.
  ELSE.
    CONCATENATE p_path c_interfacein       INTO v_interfacein.
    CONCATENATE p_path c_interfaceprocess  INTO v_interfaceprocess.
    CONCATENATE p_path c_interfaceerror    INTO v_interfaceerror.
    CONCATENATE p_path c_interfacesuccess  INTO v_interfacesuccess.
    CONCATENATE v_interfacesuccess '\' sy-datum(4) '\' sy-datum+4(2) INTO v_interfacesuccess.
    CONCATENATE p_path c_interfacedelete   INTO v_interfacedelete.
    CONCATENATE v_interfacedelete '\' sy-datum(4) '\' sy-datum+4(2) INTO v_interfacedelete.
    CONCATENATE p_path c_logfile           INTO v_logfile.
    CONCATENATE v_logfile '\' sy-datum(4) '\' sy-datum+4(2) '\idm' INTO v_logfile.
  ENDIF.

*  v_file_prefix = c_starttext.
*  IF p_start NE space.
*    v_file_prefix = p_start.
*  ENDIF.
  v_file_prefix = p_flname.

*  IF s_flname[] IS INITIAL.
  PERFORM f_get_file_name1
         USING
         v_interfacein
         all_gen          "just give all_gen as value for this parameter
         v_file_prefix.
*
  DELETE i_file_list WHERE name = '.'.
  DELETE i_file_list WHERE name = '..'.
*
*  ELSE.
*    PERFORM f_get_file_name1 USING v_interfacein.
*  ENDIF.


  SORT i_file_list BY name ASCENDING.
  v_record = 0.
  LOOP AT i_file_list.
*    WRITE: / I_FILE_LIST-NAME, SY-VLINE,
*             I_FILE_LIST-DIRNAME.
    PERFORM f_move_file   "move files using read-write operation ...
            USING i_file_list-name
                  i_file_list-name
                  v_interfacein
                  v_interfaceprocess.

    i_file_list-dirname = v_interfaceprocess.
    MODIFY i_file_list.

  ENDLOOP.

  IF sy-subrc <> 0.       "meaning no file exists in "IN" directory ..
    v_error_msg = '*********No files in IN directory**********'.
    PERFORM f_log USING v_error_msg v_logfile.   "something's wrong ;)
    EXIT.
  ENDIF.
  v_fileindex  = 0.

  LOOP AT i_file_list.

*    perform initialize_all.            "initialize all variables ...
    CLEAR: wa_itabline, itabline, v_fileindex.
    REFRESH itabline.
    PERFORM f_read_file USING i_file_list-dirname
                              i_file_list-name.

    CLEAR:  wa_itabline.
    CLEAR itab.REFRESH itab.
    LOOP AT itabline INTO wa_itabline.
      ADD 1 TO v_fileindex.
***** Proses memindahkan data ke internal table
      wa_itab = wa_itabline-v_text.
      wa_itab-index = v_fileindex.
      APPEND wa_itab TO itab.
      CLEAR: wa_itab, wa_itabline.
    ENDLOOP.

*    v_monat = i_file_list-name+3(2).
    PERFORM f_proses_data.

    MODIFY i_file_list.

    IF v_delete IS INITIAL.
      PERFORM f_split_file1
              USING i_file_list-name
                    v_interfaceprocess
                    v_interfaceerror
                    v_interfacesuccess.
      PERFORM f_delete_errlog.
    ELSE.
      ADD 1 TO va_totdelete.
      PERFORM f_file_delete USING i_file_list-name
                                  v_interfaceprocess
                                  v_interfacedelete.
      IF p_delete = 'X'.
        PERFORM f_delete_errlog.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CONCATENATE va_totdelete 'Files Deleted' INTO v_error_msg
      SEPARATED BY space.
  PERFORM f_log USING v_error_msg v_logfile.


*&---------------------------------------------------------------------*
*&      Form  ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error.
*  LOOP AT order_i WHERE vbeln EQ order_h-vbeln.
*    IF fl_matnr EQ 'X'.
*      CONCATENATE 'Doc. No.' order_h-vbeln 'Data Header Detail tidak Sama'
*            INTO v_mstring SEPARATED BY space.
*    ELSE.
*      CONCATENATE 'Doc. No.' order_h-vbeln order_i-message
*         INTO v_mstring SEPARATED BY space.
*    ENDIF.
*    LOOP AT itab WHERE index EQ order_i-index.
*      l_fileindex = itab-index.
*      PERFORM f_record_error
*           USING  i_file_list-name
*                  l_fileindex
*                 'Sales'
*                  v_mstring.
*
*    ENDLOOP.
*    DELETE order_i.
*  ENDLOOP.
*  CLEAR : order_h.
ENDFORM.                    " ERROR
*&---------------------------------------------------------------------*
*&      Form  f_proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .

  DATA: l_text(20),
        l_retcd(1),
        l_err(1),
        l_errheader(1),
        l_ctr TYPE i,
        l_split1(13),
        l_split2(2),
        l_tglpo LIKE sy-datum,
        l_err_valid(1),
        l_brtwr LIKE zsh_b2b-brtwr,
        l_b2blive LIKE zplbc-b2blive.

  CLEAR: i_matb2b, i_zsh_b2b, i_zsd_b2b, v_delete, va_totproses, va_totrecord, itab_d, wa_itab_d.
  REFRESH: i_matb2b, i_zsh_b2b, i_zsd_b2b, itab_d.

  DESCRIBE TABLE itab LINES va_totrecord.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE i_matb2b
    FROM zsmat_b2b AS a JOIN zsuom_b2b AS b ON b~zmatnr = a~zmatnr AND
                                               b~kvgr4  = a~kvgr4
    WHERE a~kvgr4 EQ p_kvgr4. "  AND
*          ( a~valid_to GE sy-datum   and   a~valid_fr <= sy-datum ).

  CLEAR: l_errheader, l_tglpo, i_b2blog.
  REFRESH: i_b2blog.
  LOOP AT itab INTO wa_itab.

    IF p_delete = 'X'.
      l_err = 'X'. v_delete = 'X'.
      l_errheader = 'X'.
      wa_itab-zst_err = 'X'.
      wa_itab-zst_delete = 'X'.
      MODIFY itab FROM wa_itab.
      CONTINUE.
    ENDIF.

    i_b2blog-zlineno = wa_itab-index.
    i_b2blog-filename = i_file_list-name.

    IF wa_itab-ztext(6) = 'ORDMSG'.
      CLEAR: wa_itab_h, l_ctr, l_brtwr,l_errheader.
      wa_itab_h = wa_itab-ztext.

      wa_itab_h-index = wa_itab-index.
      l_tglpo = wa_itab_h-po_date.

** Move To itab Update
      i_zsh_b2b-mjahr = sy-datum(4).
      i_zsh_b2b-ebeln = wa_itab_h-po_no.
      i_zsh_b2b-bedat = wa_itab_h-po_date.
      i_zsh_b2b-bnddt = wa_itab_h-exp_date.
      i_zsh_b2b-patner = wa_itab_h-kd_dc.
      i_zsh_b2b-fkdat = sy-datum.
      i_zsh_b2b-waers = 'IDR'.
      i_zsh_b2b-aedat = sy-datum.
      i_zsh_b2b-ernam = sy-uname.
      i_zsh_b2b-filename = i_file_list-name(40).

      i_b2blog-zpono = wa_itab_h-po_no.
      i_b2blog-bedat = wa_itab_h-po_date.
      i_b2blog-fkdat = sy-datum.
      i_b2blog-ernam = sy-uname.
      i_b2blog-kvgr4 = p_kvgr4.

** Check data sudah ada???
      SELECT SINGLE * FROM zsh_b2b
        WHERE ebeln = i_zsh_b2b-ebeln AND
              bedat = i_zsh_b2b-bedat.
      IF sy-subrc = 0.
        l_err = 'X'. v_delete = 'X'.
        l_errheader = 'X'.
        PERFORM error_data_ada.
*        i_b2blog-zstatus = 'X'.
*        i_b2blog-zmessage = v_mstring.
        wa_itab-zst_err = 'X'.
        wa_itab-zst_delete = 'X'.
        wa_itab-ebeln = i_zsh_b2b-ebeln.
        MODIFY itab FROM wa_itab.
*        APPEND i_b2blog.
        CONTINUE.
*        EXIT.
      ENDIF.

** Get Customer, Sloff
      CLEAR: wa_adrc, wa_cust.
      SELECT SINGLE addrnumber sort2 FROM adrc
        INTO CORRESPONDING FIELDS OF wa_adrc
        WHERE sort2 = i_zsh_b2b-patner.
      IF sy-subrc = 0.
        SELECT SINGLE adrnr kunnr vkorg vtweg spart vkbur FROM kna1vv
          INTO CORRESPONDING FIELDS OF wa_cust
          WHERE adrnr = wa_adrc-addrnumber.
        IF sy-subrc = 0.
          i_zsh_b2b-vkorg = wa_cust-vkorg.
          i_zsh_b2b-vkbur = wa_cust-vkbur.
          i_zsh_b2b-kunnr = wa_cust-kunnr.
        ELSE.
          PERFORM error_data_ada2.
          i_b2blog-zmessage = v_mstring.
          i_b2blog-zstatus = 'X'.
          APPEND i_b2blog.
          l_err = 'X'.
          l_errheader = 'X'.
          wa_itab-zst_err = 'X'.
          wa_itab-ebeln = i_zsh_b2b-ebeln.
          MODIFY itab FROM wa_itab.
          CONTINUE.
*          EXIT.
        ENDIF.
      ELSE.
        PERFORM error_data_ada2.
        i_b2blog-zmessage = v_mstring.
        i_b2blog-zstatus = 'X'.
        APPEND i_b2blog.
        l_err = 'X'.
        l_errheader = 'X'.
        wa_itab-zst_err = 'X'.
        wa_itab-ebeln = i_zsh_b2b-ebeln.
        MODIFY itab FROM wa_itab.
        CONTINUE.
*        EXIT.
      ENDIF.

** Check Cabang B2B???
      IF i_zsh_b2b-vkbur IS NOT INITIAL.
        SELECT SINGLE b2blive INTO l_b2blive
          FROM zplbc AS a JOIN tvkol AS b ON b~werks = a~werks AND
                                             b~lgort = a~lgort
          WHERE vstel = i_zsh_b2b-vkbur AND
                b2blive = 'X'.
        IF sy-subrc NE 0.
          l_err = 'X'. v_delete = 'X'.
          wa_itab-zst_err = 'X'.
          wa_itab-zst_delete = 'X'.
          l_errheader = 'X'.
          wa_itab-ebeln = i_zsh_b2b-ebeln.
          MODIFY itab FROM wa_itab.
          CONCATENATE 'Kode Cabang ' i_zsh_b2b-vkbur 'Belum go live b2b'
                          INTO v_mstring SEPARATED BY space.

          l_fileindex = wa_itab-index.
          PERFORM f_record_error
                   USING  i_file_list-name
                          l_fileindex
                          'B2B'
                          v_mstring.

*        i_b2blog-zmessage = v_mstring.
*        APPEND i_b2blog.
          wa_itab-zst_err = 'X'.
          wa_itab-ebeln = i_zsh_b2b-ebeln.
          MODIFY itab FROM wa_itab.
          CONTINUE.
        ENDIF.
      ENDIF.

      APPEND wa_itab_h TO itab_h.
      APPEND i_zsh_b2b.
      va_totproses = va_totproses + 1.

    ELSEIF wa_itab-ztext(6) = 'ORDDTL'.
** Header Error
      IF l_errheader = 'X'.
        IF v_delete = 'X'.
          CONTINUE.
        ENDIF.
        v_mstring = 'Lihat error Header'.
        l_fileindex = wa_itab-index.
        PERFORM f_record_error
                 USING  i_file_list-name
                        l_fileindex
                        'B2B'
                        v_mstring.
        i_b2blog-zmessage = v_mstring.
        APPEND i_b2blog.
        wa_itab-zst_err = 'X'.
        wa_itab-ebeln = i_zsh_b2b-ebeln.
        MODIFY itab FROM wa_itab.
        CLEAR l_errheader.
        CONTINUE.
      ENDIF.

      CLEAR: wa_itab_d.
      wa_itab_d = wa_itab-ztext.

      CLEAR: i_matb2b.
      l_err_valid = 'X'.
      LOOP AT i_matb2b WHERE zmatnr = wa_itab_d-plu AND
                             kvgr4  = p_kvgr4." AND
*                             bstme  = wa_itab_d-uom.
        IF  l_tglpo >= i_matb2b-valid_fr AND l_tglpo <= i_matb2b-valid_to.
          CLEAR: l_err_valid.
          EXIT.
        ENDIF.
      ENDLOOP.
*      READ TABLE i_matb2b WITH KEY zmatnr = wa_itab_d-plu
*                                   kunnr  = p_cust
*                                   bstme  = wa_itab_d-uom.
      IF l_err_valid = 'X'.
        PERFORM error_data_ada1.
        i_b2blog-zmessage = v_mstring.
        APPEND i_b2blog.
        wa_itab-zst_err = 'X'.
        wa_itab-ebeln = i_zsh_b2b-ebeln.
        MODIFY itab FROM wa_itab.
        l_err = 'X'.
        CONTINUE.
      ENDIF.

      wa_itab_d-po_no = wa_itab_h-po_no.
      wa_itab_d-index = wa_itab-index.
      APPEND wa_itab_d TO itab_d.
      ADD 10 TO l_ctr.

** Move To itab Update
      i_zsd_b2b-ebeln = i_zsh_b2b-ebeln.
      i_zsd_b2b-znob2b = i_zsh_b2b-znob2b.
      i_zsd_b2b-ebelp = l_ctr.
      i_zsd_b2b-matnr = i_matb2b-matnr.
      i_zsd_b2b-material = wa_itab_d-plu.
      i_zsd_b2b-qtybx = wa_itab_d-qty.
      i_zsd_b2b-conve = 1.

*      wa_itab_d-qty_pcs =  wa_itab_d-qty * i_matb2b-doqty.
*      wa_itab_d-qty_crt =  wa_itab_d-qty_crt * ( wa_itab_d-cnv * i_matb2b-doqty ).
*      i_zsd_b2b-menge = ( wa_itab_d-qty_pcs + wa_itab_d-qty_crt ) / i_matb2b-poqty.
      i_zsd_b2b-menge = wa_itab_d-qty * i_matb2b-doqty / i_matb2b-poqty.

      REPLACE ',' WITH '.' INTO wa_itab_d-total.
      i_zsd_b2b-meins = i_matb2b-vrkme.
*      i_zsd_b2b-netwr = wa_itab_d-total.
      i_zsd_b2b-kzwi1 = wa_itab_d-harga / 100.
      i_zsd_b2b-kzwi2 = wa_itab_d-bonus1 / 100.
      i_zsd_b2b-kzwi3 = wa_itab_d-bonus2 / 100.
*      i_zsd_b2b-brtwr = i_zsd_b2b-qtybx * i_zsd_b2b-kzwi1 * 11 / 10.
      i_zsd_b2b-brtwr = wa_itab_d-total / 100.
      i_zsd_b2b-waers = 'IDR'.

      APPEND i_zsd_b2b.
      va_totproses = va_totproses + 1.

    ENDIF.

    itab-ebeln = i_zsh_b2b-ebeln.
    MODIFY itab TRANSPORTING ebeln.
    CLEAR: wa_itab.
  ENDLOOP.

  LOOP AT itab INTO wa_itab WHERE zst_err = 'X'.
    LOOP AT itab INTO wa_itab1 WHERE ebeln = wa_itab-ebeln AND
                                     zst_err = ' '.
      v_mstring = '--- Lihat error Item ---'.
      l_fileindex = wa_itab1-index.
      PERFORM f_record_error
        USING  i_file_list-name
               l_fileindex
               'B2B'
               v_mstring.
      wa_itab1-zst_err = 'X'.
      MODIFY itab FROM wa_itab1.
      va_totproses = va_totproses - 1.
    ENDLOOP.
    LOOP AT itab_h INTO wa_itab_h.
      IF wa_itab_h-po_no = wa_itab-ebeln.
        DELETE itab_h.
        DELETE itab_d WHERE po_no = wa_itab_h-po_no.
      ENDIF.
    ENDLOOP.
    DELETE i_zsh_b2b WHERE ebeln = wa_itab-ebeln.
    DELETE i_zsd_b2b WHERE ebeln = wa_itab-ebeln.
    SORT i_itaberror_desc BY filename file_index.
    CLEAR: wa_itab.
  ENDLOOP.

*  IF l_err = 'X' OR v_delete = 'X'.
  IF v_delete = 'X'.
    CLEAR va_totproses.
  ENDIF.

  i_file_list-num_valid_record = va_totproses.
  i_file_list-num_record = va_totrecord.
  IF i_b2blog IS INITIAL.
  ELSE.
    LOOP AT i_b2blog.
      MOVE-CORRESPONDING  i_b2blog TO zsb2b_errlog.
      MODIFY zsb2b_errlog.
    ENDLOOP.
  ENDIF.

*  CHECK l_err IS INITIAL.

** Get Runing Number
  LOOP AT i_zsh_b2b.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZSD_B2B'
      IMPORTING
        returncode  = l_retcd
        number      = i_zsh_b2b-znob2b.

    CLEAR: i_zsd_b2b.
    LOOP AT i_zsd_b2b WHERE ebeln = i_zsh_b2b-ebeln.
      ADD i_zsd_b2b-brtwr TO i_zsh_b2b-brtwr.
      i_zsd_b2b-znob2b = i_zsh_b2b-znob2b.
      MODIFY i_zsd_b2b TRANSPORTING znob2b.
    ENDLOOP.
    MODIFY i_zsh_b2b TRANSPORTING znob2b brtwr.

    MOVE-CORRESPONDING i_zsh_b2b TO i_sukses.
    APPEND i_sukses.
  ENDLOOP.

** Material Substitusi per Sales Office
  CALL FUNCTION 'ZSB2B_MATNR'
    TABLES
      pt_zsh_b2b = i_zsh_b2b
      pt_zsd_b2b = i_zsd_b2b.

** Update table B2B
  IF i_zsh_b2b[] IS NOT INITIAL.
    MODIFY zsh_b2b FROM TABLE i_zsh_b2b.
    MODIFY zsd_b2b FROM TABLE i_zsd_b2b.
  ENDIF.

  LOOP AT itab_h INTO wa_itab_h.
    WRITE: / '--- Header ---'.
    WRITE: / wa_itab_h-type, sy-vline,
             wa_itab_h-po_no, sy-vline,
             wa_itab_h-po_date, sy-vline,
             wa_itab_h-exp_date, sy-vline,
             wa_itab_h-sen_name, sy-vline,
             wa_itab_h-sup_code, sy-vline,
             wa_itab_h-sup_name, sy-vline,
             wa_itab_h-kd_unit, sy-vline,
             wa_itab_h-kd_dc.
    WRITE: / '--- Detail ---'.
    LOOP AT itab_d INTO wa_itab_d WHERE po_no = wa_itab_h-po_no.
      WRITE:/  wa_itab_d-type, sy-vline,
               wa_itab_d-barcode, sy-vline,
               wa_itab_d-qty, sy-vline,
               wa_itab_d-satuan, sy-vline,
               wa_itab_d-harga, sy-vline,
               wa_itab_d-plu, sy-vline,
               wa_itab_d-desc, sy-vline,
               wa_itab_d-bonus1, sy-vline,
               wa_itab_d-bonus2, sy-vline,
               wa_itab_d-total.
    ENDLOOP.
    SKIP.
  ENDLOOP.

ENDFORM.                    " f_proses_data

*&---------------------------------------------------------------------*
*&      Form  error_data_ada1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_data_ada1 .
  CONCATENATE 'Material' wa_itab_d-plu 'Belum ada di maping table'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = wa_itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.
ENDFORM.                    " error_data_ada1

*&---------------------------------------------------------------------*
*&      Form  error_data_ada2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_data_ada2 .
  CONCATENATE 'Cust. code' wa_itab_h-kd_dc 'Belum ada di master data'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = wa_itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.
ENDFORM.                    " error_data_ada1

*---------------------------------------------------------------------*
*       FORM f_file delete                                            *
*---------------------------------------------------------------------*
* Routine for splitting files in file list. Files which contain no    *
* errors are moved to archive directory. Files which all lines are error
* are moved to error directory. Whereas, files which contain error are
* splitted into two different directories
*---------------------------------------------------------------------*
* INPUT :
*  - p_filename  : source directory
*  - pdir_src    : source directory
*  - pdir_delete : failed directory, where error files are kept
* PROCESS :
*  - if file delete, move directly to pdir_delete
*  - delete file in source directory
*---------------------------------------------------------------------*

FORM f_file_delete USING p_filename TYPE c
                         pdir_src TYPE c
                         pdir_delete TYPE c.

  DATA : l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filename_src(125) TYPE c,
         l_extension(5) TYPE c.

  SPLIT p_filename AT '.' INTO l_filename l_extension.
  CONCATENATE l_filename '_DLT' '.' l_extension INTO l_filename_dest.
  PERFORM f_move_file USING p_filename
                            l_filename_dest
                            pdir_src
                            pdir_delete.

*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    CONCATENATE pdir_delete '/' l_filename_dest INTO l_filename_dest.
  ELSE.
    CONCATENATE pdir_delete '\' l_filename_dest INTO l_filename_dest.
  ENDIF.
  PERFORM f_changefilemode USING l_filename_dest.

ENDFORM.                    "f_file_delete
*&---------------------------------------------------------------------*
*&      Form  error_data_ada
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_data_ada .
  CONCATENATE 'PO No. ' wa_itab_h-po_no 'Sudah ada ditable'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = wa_itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

ENDFORM.                    " error_data_ada

*&---------------------------------------------------------------------*
*&      Form  f_delete_errlog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_errlog .

  DATA: lt_zsb2b_errlog LIKE zsb2b_errlog OCCURS 0 WITH HEADER LINE,
        ld_pono  LIKE zsb2b_errlog-zpono,
        ld_bedat LIKE zsb2b_errlog-bedat.

  IF i_sukses[] IS NOT INITIAL OR p_delete = 'X'.
    CLEAR itab.
    READ TABLE itab WITH KEY INDEX = 1.
    ld_pono  = itab+43(9).
    ld_bedat = itab+53(8).
    DELETE FROM zsb2b_errlog WHERE zpono = ld_pono AND
                                   bedat = ld_bedat.

*  ELSE.
*    IF i_sukses[] IS NOT INITIAL.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zsb2b_errlog
*        FROM zsb2b_errlog
*        FOR ALL ENTRIES IN i_sukses
*        WHERE zpono = i_sukses-ebeln AND
*              bedat = i_sukses-bedat.
*      DELETE zsb2b_errlog FROM TABLE lt_zsb2b_errlog.
*    ENDIF.
  ENDIF.

ENDFORM.                    " f_delete_errlog

*---------------------------------------------------------------------*
*       FORM f_split_file1                                             *
*---------------------------------------------------------------------*
* Routine for splitting files in file list. Files which contain no    *
* errors are moved to archive directory. Files which all lines are error
* are moved to error directory. Whereas, files which contain error are
* splitted into two different directories
*---------------------------------------------------------------------*
* INPUT :
*  - pdir_src : source directory
*  - pdir_failed : failed directory, where error files are kept
*  - pdir_ok : success directory, where successful files are kept
* PROCESS :
*  - if file contains no error, move directly to pdir_ok
*  - if all lines in file are error, move directly to pdir_failed
*  - otherwise, read each line of file. If there is no error in the
*    line, write it to file in pdir_ok. Otherwise, write it to file
*    in pdir_failed.
*  - delete file in source directory
*---------------------------------------------------------------------*

FORM f_split_file1 USING p_filename TYPE c
                         pdir_src TYPE c
                         pdir_failed TYPE c
                         pdir_ok TYPE c.

  DATA : l_errorfilename(125) TYPE c,
         l_okfilename(125) TYPE c,
         l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filename_src(125) TYPE c,
         l_text(1500) TYPE c,
         l_iserror TYPE c VALUE 'F',
         l_index TYPE i,
         l_extension(5) TYPE c,
         l_error_record TYPE i.

  DATA: l_flname(125) TYPE c,
        l_txt(5)     TYPE c.

  CLEAR wa_itaberror.
  READ TABLE i_itaberror INTO wa_itaberror WITH KEY filename = p_filename.
  IF sy-subrc NE 0.                    "not exist
    SPLIT p_filename AT '.' INTO l_filename l_extension.
    SPLIT l_filename AT '_OK' INTO l_flname l_txt.
*    CONCATENATE l_filename '_OK' '.' l_extension INTO l_filename_dest.
    CONCATENATE l_flname '_OK' '.' l_extension INTO l_filename_dest.
    PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_ok.

*{   REPLACE        P01K910797                                        3
*\    IF sy-opsys EQ 'AIX'.
    IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
      CONCATENATE pdir_ok '/' l_filename_dest INTO l_filename_dest.
    ELSE.
      CONCATENATE pdir_ok '\' l_filename_dest INTO l_filename_dest.
    ENDIF.
    PERFORM f_changefilemode USING l_filename_dest.

  ELSE.                                "exist, split!
    l_error_record = i_file_list-num_record -
        i_file_list-num_valid_record .
    IF i_file_list-num_record =  l_error_record.
*    if wa_itaberror-all eq 'T' .       "all records are false
      SPLIT p_filename AT '.' INTO l_filename l_extension.
      SPLIT l_filename AT '_ER' INTO l_flname l_txt.
*      CONCATENATE l_filename '_ER' '.' l_extension INTO l_filename_dest.
      CONCATENATE l_flname '_ER' '.' l_extension INTO l_filename_dest.
      PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_failed.
      wa_itaberror-filename = l_filename_dest.
      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.
*{   REPLACE        P01K910797                                        2
*\      IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename_dest INTO l_filename_dest.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename_dest INTO l_filename_dest.
      ENDIF.
      PERFORM f_changefilemode USING l_filename_dest.
    ELSE.

      SPLIT p_filename AT '.' INTO l_filename l_extension.
*{   REPLACE        P01K910797                                        1
*\      IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '/' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '/'
             wa_itaberror-filename INTO l_filename_src.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '\' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '\'
             wa_itaberror-filename INTO l_filename_src.
      ENDIF.
      OPEN DATASET l_filename_src FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      OPEN DATASET l_errorfilename FOR APPENDING IN TEXT MODE ENCODING DEFAULT.

      OPEN DATASET l_okfilename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

      l_index = 1.

      DO.
        READ DATASET l_filename_src INTO l_text.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        PERFORM f_check_index
                   USING
                      l_index
                   CHANGING
                      l_iserror.

        IF l_text NE ''.
          IF l_iserror = 'T'.
            TRANSFER l_text TO l_errorfilename.
          ELSE.
            TRANSFER l_text TO l_okfilename.
          ENDIF.
        ENDIF.
        l_index = l_index + 1.
      ENDDO.
      CLOSE DATASET l_okfilename.
      CLOSE DATASET l_errorfilename.
      CLOSE DATASET l_filename_src.
      DELETE DATASET l_filename_src.

*     chmod 777
      PERFORM f_changefilemode USING l_okfilename.
      PERFORM f_changefilemode USING l_errorfilename.

*      CONCATENATE l_filename '_ER' '.' l_extension INTO
*        wa_itaberror-filename.
      CONCATENATE l_flname '_ER' '.' l_extension INTO
        wa_itaberror-filename.

      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.

    ENDIF.

  ENDIF.

ENDFORM.                    "f_split_file1

*---------------------------------------------------------------------*
*       FORM f_get_file_name1                                         *
*---------------------------------------------------------------------*
* Routine for getting contents of one directory with particular pattern
*---------------------------------------------------------------------*
* INPUT :
*   -p_dir_name : directory name
*   -p_generic_name : generic filename (e.g : *)
*   -p_must_cs : pattern for legal filenames. Valid value : NO_CS (no *
*pattern ) , %, etc.
* OUTPUT :
*    - list of file with the specified pattern, kept in FILE_LIST table.
*---------------------------------------------------------------------*

FORM f_get_file_name1 USING p_dir_name TYPE c
                            p_generic_name TYPE c
                            p_must_cs TYPE c.
  DATA: l_errcnt(2) TYPE p VALUE 0,
        l_must_cs(60) TYPE c.

  IF p_dir_name IS INITIAL.
*     MESSAGE E220.     " 'Place cursor on valid line !'.
  ENDIF.

  CALL 'C_DIR_READ_FINISH'             " just to be sure
      ID 'ERRNO'  FIELD i_file_list-errno
      ID 'ERRMSG' FIELD i_file_list-errmsg.

  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD p_dir_name
                          ID 'FILE'   FIELD p_generic_name
                          ID 'ERRNO'  FIELD file-errno
                          ID 'ERRMSG' FIELD file-errmsg.
  IF sy-subrc <> 0.
*    MESSAGE E204 WITH FILE_LIST-ERRMSG FILE-ERRMSG.
  ENDIF.

  DO.
    CLEAR file.
    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD file-type
      ID 'NAME'   FIELD file-name
      ID 'LEN'    FIELD file-len
      ID 'OWNER'  FIELD file-owner
      ID 'MTIME'  FIELD file-mtime
      ID 'MODE'   FIELD file-mode
      ID 'ERRNO'  FIELD file-errno
      ID 'ERRMSG' FIELD file-errmsg.
    file-dirname = p_dir_name.
    MOVE sy-subrc TO file-subrc.
    CASE sy-subrc.
      WHEN 0.
        CLEAR: file-errno, file-errmsg.
        CASE file-type(1).
          WHEN 'F'.                    " normal file.
            PERFORM filename_useable USING file-name file-useable.
          WHEN 'f'.                    " normal file.
            PERFORM filename_useable USING file-name file-useable.
          WHEN OTHERS. " directory, device, fifo, socket,...
            MOVE sap_no  TO file-useable.
        ENDCASE.
        IF file-len = 0.
          MOVE sap_no TO file-useable.
        ENDIF.
      WHEN 1.
        EXIT.
      WHEN OTHERS.                     " SY-SUBRC >= 2
        ADD 1 TO l_errcnt.
        IF l_errcnt > 10.
          EXIT.
        ENDIF.
        IF sy-subrc = 5.
          MOVE: '???' TO file-type,
                '???' TO file-owner,
                '???' TO file-mode.
        ELSE.
*         ULINE.
*         WRITE: / 'C_DIR_READ_NEXT', 'SUBRC', SY-SUBRC.
        ENDIF.
        MOVE sap_no TO file-useable.
    ENDCASE.
    PERFORM p6_to_date_time_tz(rstr0400) USING file-mtime
                                               file-mod_time
                                               file-mod_date.
*   * Does the filename contains the requested pattern?
*   * Then store it, else forget it.
    IF p_must_cs = no_cs.
      MOVE-CORRESPONDING file TO i_file_list.
      APPEND i_file_list.
    ELSE.
      CONCATENATE p_must_cs '*' INTO l_must_cs.
      IF file-name CP l_must_cs.
        MOVE-CORRESPONDING file TO i_file_list.
        APPEND i_file_list.
      ENDIF.
    ENDIF.
  ENDDO.

  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD i_file_list-errno
      ID 'ERRMSG' FIELD i_file_list-errmsg.
  IF sy-subrc <> 0.
    WRITE: / 'C_DIR_READ_FINISH', 'SUBRC', sy-subrc.
  ENDIF.
  IF srt = 'T'.
    SORT i_file_list BY mtime DESCENDING name ASCENDING.
  ELSE.
    SORT i_file_list BY name ASCENDING mtime DESCENDING.
  ENDIF.

ENDFORM.                    "f_get_file_name1
