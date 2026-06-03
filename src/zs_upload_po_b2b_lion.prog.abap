REPORT zs_upload_po_b2b_lion NO STANDARD PAGE HEADING MESSAGE-ID 00
                             LINE-SIZE 170.
TABLES : zsh_b2b, zsd_b2b, zsmat_b2b, zsb2b_errlog, knvv.
TYPE-POOLS: abap.

INCLUDE zvx_interface_incl.

DATA: BEGIN OF itab OCCURS 0,
           ztext(500),
           index TYPE i,
           zst_err(1),
           zst_delete(1),
           zstatus(1),
      END OF itab.

DATA: BEGIN OF i_b2blog OCCURS 0.
        INCLUDE STRUCTURE   zsb2b_errlog.
DATA:      zstatus(1),
      END OF i_b2blog.

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

DATA: i_zsh_b2b LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
      i_zsd_b2b LIKE zsd_b2b OCCURS 0 WITH HEADER LINE,
      i_sukses LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
      wa_itab LIKE itab,
      v_delete(1),
      l_err(1),
      l_errheader(1).

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
  c_interfacedelete(125)  TYPE c VALUE '\delete',
  c_logfile(125)          TYPE c VALUE '\log',

  c_interfacein_aix(125)      TYPE c VALUE '/in',
  c_interfaceprocess_aix(125) TYPE c VALUE '/process',
  c_interfacesuccess_aix(125) TYPE c VALUE '/archive',
  c_interfaceerror_aix(125)   TYPE c VALUE '/in',
  c_interfacedelete_aix(125)  TYPE c VALUE '/delete',
  c_logfile_aix(125)          TYPE c VALUE '/log'.

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
        va_totproses TYPE i,
        va_totrecord TYPE i,va_ctr TYPE i,
        va_toterror  TYPE i,
        va_totdelete  TYPE n,
        c_starttext(20) TYPE c.

TYPES: BEGIN OF ts_po_header,
         po_no(10),
         po_date(11),
         top_sup(5),
         supp_code(10),
         supp_name(100),
         supp_pkp(20),
         supp_telp(60),
         supp_fax(60),
         supp_contact(100),
END OF ts_po_header.

TYPES: BEGIN OF ts_po_detail,
         plu(7),
         barcode(20),
         description(100),
         unit(5),
         conversion(5),
         qty(20),
         bonus1(10),
         bonus2(10),
         price(20),
         discount(20),
         ppn(20),
         ppnbm(20),
         package(10),
         total(20),
END OF ts_po_detail.

TYPES: BEGIN OF ts_po_footer,
         store_id(5),
         store(60),
         address(100),
         telp(60),
         note(100),
         tax_name(100),
         tax_address(100),
         tax_npwp(20),
         pb_no(10),
         expired(11),
         delivery(11),
         po_division(10),
         orderby(3),
         announcement(200),
END OF ts_po_footer.

DATA: gt_po_header      TYPE STANDARD TABLE OF ts_po_header,
      gs_po_header      TYPE ts_po_header,
      gt_po_detail      TYPE STANDARD TABLE OF ts_po_detail,
      gs_po_detail      TYPE ts_po_detail,
      gt_po_footer      TYPE STANDARD TABLE OF ts_po_footer,
      gs_po_footer      TYPE ts_po_footer.

DATA: gt_result_xml  TYPE abap_trans_resbind_tab,
      gs_result_xml  TYPE abap_trans_resbind.
DATA: gs_rif_ex      TYPE REF TO cx_root,
      gs_var_text    TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK aaa WITH FRAME TITLE text-aaa.
PARAMETERS: p_path(125) DEFAULT '\\tdsdev01\interface\B2B\lion' LOWER CASE,
            p_kvgr4 LIKE zsmat_b2b-kvgr4 OBLIGATORY,
            p_flname LIKE zsb2b_errlog-filename NO-DISPLAY,
            p_delete(1) NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK aaa.

INITIALIZATION.
*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    p_path = '/interface/B2B/lion'.
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
    CONCATENATE v_logfile '/' sy-datum(4) '/' sy-datum+4(2) '/lion' INTO v_logfile.
  ELSE.
    CONCATENATE p_path c_interfacein       INTO v_interfacein.
    CONCATENATE p_path c_interfaceprocess  INTO v_interfaceprocess.
    CONCATENATE p_path c_interfaceerror    INTO v_interfaceerror.
    CONCATENATE p_path c_interfacesuccess  INTO v_interfacesuccess.
    CONCATENATE v_interfacesuccess '\' sy-datum(4) '\' sy-datum+4(2) INTO v_interfacesuccess.
    CONCATENATE p_path c_interfacedelete   INTO v_interfacedelete.
    CONCATENATE v_interfacedelete '\' sy-datum(4) '\' sy-datum+4(2) INTO v_interfacedelete.
    CONCATENATE p_path c_logfile           INTO v_logfile.
    CONCATENATE v_logfile '\' sy-datum(4) '\' sy-datum+4(2) '\lion' INTO v_logfile.
  ENDIF.

  v_file_prefix = p_flname.

  PERFORM f_get_file_name USING v_interfacein all_gen v_file_prefix.

  DELETE i_file_list WHERE name = '.'.
  DELETE i_file_list WHERE name = '..'.

  SORT i_file_list BY name ASCENDING.
  v_record = 0.
  LOOP AT i_file_list.
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
    CLEAR: wa_itabline, itabline, v_fileindex, gs_var_text,
           l_err, l_errheader.
    REFRESH itabline.
    PERFORM f_read_file1 USING i_file_list-dirname
                               i_file_list-name.

*    CLEAR:  wa_itabline.
*    CLEAR itab.REFRESH itab.
*    LOOP AT itabline INTO wa_itabline.
*      ADD 1 TO v_fileindex.
****** Proses memindahkan data ke internal table
*      wa_itab = wa_itabline-v_text.
*      wa_itab-index = v_fileindex.
*      APPEND wa_itab TO itab.
*      CLEAR: wa_itab, wa_itabline.
*    ENDLOOP.

**    v_monat = i_file_list-name+3(2).
    IF gs_var_text IS INITIAL.
      PERFORM f_proses_data.
    ENDIF.

    MODIFY i_file_list.

    IF v_delete IS INITIAL.
      PERFORM f_split_file1 USING i_file_list-name
                                  v_interfaceprocess
                                  v_interfaceerror
                                  v_interfacesuccess.
      IF p_delete = 'X'.
        PERFORM f_delete_errlog.
      ENDIF.
    ELSE.
      ADD 1 TO va_totdelete.
      PERFORM f_file_delete USING i_file_list-name
                                  v_interfaceprocess
                                  v_interfacedelete.
      PERFORM f_delete_errlog.
    ENDIF.
  ENDLOOP.

  CONCATENATE va_totdelete 'Files Deleted' INTO v_error_msg
      SEPARATED BY space.
  PERFORM f_log USING v_error_msg v_logfile.


*&---------------------------------------------------------------------*
*&      Form  f_proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: l_retcd(1),
*        l_err(1),
*        l_errheader(1),
        l_ctr TYPE i,
        l_tglpo LIKE sy-datum,
        l_err_valid(1),
        l_b2blive LIKE zplbc-b2blive.

  DATA: ld_datum  LIKE sy-datum,
        ld_netwr  LIKE zsh_b2b-netwr,
        ld_brtwr  LIKE zsh_b2b-brtwr,
        ld_mwsbk  LIKE zsh_b2b-mwsbk,
        ld_tdisa  LIKE zsh_b2b-tdisa.

  CLEAR: i_matb2b, i_zsh_b2b, i_zsd_b2b, v_delete, va_totproses, va_totrecord.
  REFRESH: i_matb2b, i_zsh_b2b, i_zsd_b2b.

  DESCRIBE TABLE itab LINES va_totrecord.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE i_matb2b
    FROM zsmat_b2b AS a JOIN zsuom_b2b AS b ON b~zmatnr = a~zmatnr AND
                                               b~kvgr4  = a~kvgr4
    WHERE a~kvgr4 EQ p_kvgr4. "  AND
  CLEAR: l_errheader, l_tglpo.

  i_zsh_b2b-mjahr  = sy-datum(4).

  i_b2blog-zlineno = wa_itab-index.
  i_b2blog-filename = i_file_list-name.

  READ TABLE gt_po_header INTO gs_po_header INDEX 1.
  IF sy-subrc EQ 0.
    i_zsh_b2b-ebeln  = gs_po_header-po_no.
    PERFORM f_date_convert USING gs_po_header-po_date
                           CHANGING ld_datum.
    i_zsh_b2b-bedat  = ld_datum.
    l_tglpo          = ld_datum.
    i_zsh_b2b-waers  = 'IDR'.

    i_b2blog-zpono = gs_po_header-po_no.
    i_b2blog-bedat = ld_datum.
    i_b2blog-fkdat = sy-datum.
    i_b2blog-ernam = sy-uname.
    i_b2blog-kvgr4 = p_kvgr4.

** Check data sudah ada???
    SELECT SINGLE * FROM zsh_b2b
      WHERE ebeln = i_zsh_b2b-ebeln AND
            bedat = i_zsh_b2b-bedat.
    IF sy-subrc EQ 0.
      l_err = 'X'. v_delete = 'X'.
      l_errheader = 'X'.
      PERFORM error_data_ada USING gs_po_header-po_no.
    ENDIF.
  ENDIF.

  IF l_err IS INITIAL.
    READ TABLE gt_po_footer INTO gs_po_footer INDEX 1.
    IF sy-subrc EQ 0.
      PERFORM f_date_convert USING gs_po_footer-expired
                           CHANGING ld_datum.
      i_zsh_b2b-bnddt   = ld_datum.
      i_zsh_b2b-patner  = gs_po_footer-store_id.

** Get Customer, Sloff
      CLEAR: wa_adrc, wa_cust.
      SELECT SINGLE addrnumber sort2 FROM adrc
        INTO CORRESPONDING FIELDS OF wa_adrc
        WHERE sort2 = i_zsh_b2b-patner.
      IF sy-subrc EQ 0.
        SELECT SINGLE adrnr kunnr vkorg vtweg spart vkbur FROM kna1vv
          INTO CORRESPONDING FIELDS OF wa_cust
          WHERE adrnr = wa_adrc-addrnumber.
        IF sy-subrc EQ 0.
          i_zsh_b2b-vkorg = wa_cust-vkorg.
          i_zsh_b2b-vkbur = wa_cust-vkbur.
          i_zsh_b2b-kunnr = wa_cust-kunnr.

          DELETE FROM zsb2b_errlog WHERE zpono    EQ i_b2blog-zpono AND
                                         zmessage LIKE 'Cust. code%' AND
                                         filename EQ i_b2blog-filename.
        ENDIF.
      ELSE.
        l_err = 'X'.
        l_errheader = 'X'.
        PERFORM error_data_ada2 USING i_zsh_b2b-patner.
      ENDIF.

** Check Cabang B2B???
      IF i_zsh_b2b-vkbur IS NOT INITIAL.
        SELECT SINGLE b2blive INTO l_b2blive
          FROM zplbc AS a JOIN tvkol AS b ON b~werks = a~werks AND
                                             b~lgort = a~lgort
          WHERE vstel = i_zsh_b2b-vkbur AND
                b2blive = 'X'.
        IF sy-subrc NE 0.
          l_err = 'X'.
          l_errheader = 'X'.
          PERFORM error_data_ada3 USING i_zsh_b2b-vkbur.
        ELSE.
          DELETE FROM zsb2b_errlog WHERE zpono    EQ i_b2blog-zpono AND
                                         zmessage LIKE 'Kode Cabang%' AND
                                         filename EQ i_b2blog-filename.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF l_err IS INITIAL.
    CLEAR: ld_netwr, ld_brtwr.
    LOOP AT gt_po_detail INTO gs_po_detail WHERE barcode NE space.
      ADD 10 TO l_ctr.
      i_zsd_b2b-ebelp  = l_ctr.

      CLEAR: i_matb2b.
      l_err_valid = 'X'.
      LOOP AT i_matb2b WHERE zmatnr = gs_po_detail-plu AND
                             kvgr4  = p_kvgr4.
        IF  l_tglpo >= i_matb2b-valid_fr AND l_tglpo <= i_matb2b-valid_to.
          CLEAR: l_err_valid.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF l_err_valid EQ 'X'.
        PERFORM error_data_ada1 USING gs_po_detail-plu.
        l_err = 'X'.
      ELSE.
        i_zsd_b2b-matnr    = i_matb2b-matnr.
        i_zsd_b2b-material = gs_po_detail-plu.
        i_zsd_b2b-brtwr    = gs_po_detail-total / 100.
        i_zsd_b2b-waers    = 'IDR'.
        IF gs_po_detail-conversion IS INITIAL.
          i_zsd_b2b-netwr  = 0.
          i_zsd_b2b-kzwi1  = 0.
        ELSE.
          i_zsd_b2b-netwr    = ( ( ( gs_po_detail-price / gs_po_detail-conversion ) *
                                gs_po_detail-qty ) - gs_po_detail-discount ) / 100.
          i_zsd_b2b-kzwi1    = ( gs_po_detail-price / gs_po_detail-conversion ) / 100.
        ENDIF.

        i_zsd_b2b-kzwi2    = gs_po_detail-discount.
        i_zsd_b2b-meins    = i_matb2b-vrkme.
        i_zsd_b2b-conve    = gs_po_detail-conversion.
        i_zsd_b2b-qtypc    = gs_po_detail-qty.
        IF i_matb2b-poqty IS NOT INITIAL.
          i_zsd_b2b-menge    = ( i_zsd_b2b-qtypc * i_matb2b-doqty ) / i_matb2b-poqty.
        ELSE.
          i_zsd_b2b-menge    = 0.
        ENDIF.
        APPEND i_zsd_b2b.

        ADD i_zsd_b2b-netwr TO ld_netwr.
        ADD i_zsd_b2b-brtwr TO ld_brtwr.
        ADD gs_po_detail-ppn TO ld_mwsbk.
        ADD i_zsd_b2b-kzwi2 TO ld_tdisa.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF i_b2blog[] IS INITIAL.
  ELSE.
    LOOP AT i_b2blog.
      MOVE-CORRESPONDING  i_b2blog TO zsb2b_errlog.
      MODIFY zsb2b_errlog.
    ENDLOOP.
  ENDIF.

  CHECK l_err IS INITIAL.

  i_zsh_b2b-mwsbk     = ld_mwsbk / 100.
  i_zsh_b2b-tdisa     = ld_tdisa / 100.
  i_zsh_b2b-netwr     = ld_netwr.
  i_zsh_b2b-brtwr     = ld_brtwr.
  i_zsh_b2b-fkdat     = sy-datum.
  i_zsh_b2b-ernam     = sy-uname.
  i_zsh_b2b-filename  = i_file_list-name(40).

** Get Runing Number
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZSD_B2B'
    IMPORTING
      returncode  = l_retcd
      number      = i_zsh_b2b-znob2b.

  APPEND i_zsh_b2b.
  CLEAR: i_zsd_b2b.
  i_zsd_b2b-znob2b = i_zsh_b2b-znob2b.
  MODIFY i_zsd_b2b TRANSPORTING znob2b WHERE znob2b IS INITIAL.

  MOVE-CORRESPONDING i_zsh_b2b TO i_sukses.
  APPEND i_sukses.

** Material Substitusi per Sales Office
  CALL FUNCTION 'ZSB2B_MATNR'
    TABLES
      pt_zsh_b2b = i_zsh_b2b
      pt_zsd_b2b = i_zsd_b2b.

** Update table B2B
  MODIFY zsh_b2b FROM TABLE i_zsh_b2b.
  MODIFY zsd_b2b FROM TABLE i_zsd_b2b.
ENDFORM.                    " f_proses_data

*&---------------------------------------------------------------------*
*&      Form  error_data_ada
*&---------------------------------------------------------------------*
FORM error_data_ada USING fu_pono.
  CONCATENATE 'PO No. ' fu_pono 'Sudah ada ditable'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  APPEND i_b2blog.
ENDFORM.                    " error_data_ada

*&---------------------------------------------------------------------*
*&      Form  error_data_ada1
*&---------------------------------------------------------------------*
FORM error_data_ada1 USING fu_plu.
  CONCATENATE 'Material' fu_plu 'Belum ada di maping table'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  i_b2blog-zlineno = i_zsd_b2b-ebelp.
  APPEND i_b2blog.
ENDFORM.                    " error_data_ada1

*&---------------------------------------------------------------------*
*&      Form  error_data_ada2
*&---------------------------------------------------------------------*
FORM error_data_ada2 USING fu_store.
  CONCATENATE 'Cust. code' fu_store 'Belum ada di master data'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  APPEND i_b2blog.
ENDFORM.                    " error_data_ada2

*&---------------------------------------------------------------------*
*&      Form  ERROR_DATA_ADA3
*&---------------------------------------------------------------------*
FORM error_data_ada3  USING    fu_vkbur.
  CONCATENATE 'Kode Cabang ' fu_vkbur 'Belum go live b2b'
                  INTO v_mstring SEPARATED BY space.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  APPEND i_b2blog.
ENDFORM.                    " ERROR_DATA_ADA3

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
    DELETE FROM zsb2b_errlog WHERE zpono = i_zsh_b2b-ebeln AND
                                   bedat = i_zsh_b2b-bedat.
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
    p_delete = 'X'.
    SPLIT p_filename AT '.' INTO l_filename l_extension.
    SPLIT l_filename AT '_OK' INTO l_flname l_txt.
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
      SPLIT p_filename AT '.' INTO l_filename l_extension.
      SPLIT l_filename AT '_ER' INTO l_flname l_txt.
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
      OPEN DATASET l_filename_src FOR INPUT IN text mode ENCODING DEFAULT.
      OPEN DATASET l_errorfilename FOR APPENDING IN text mode ENCODING DEFAULT.

      OPEN DATASET l_okfilename FOR OUTPUT IN text mode ENCODING DEFAULT.

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

      CONCATENATE l_flname '_ER' '.' l_extension INTO
        wa_itaberror-filename.

      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_split_file1

*---------------------------------------------------------------------*
*       FORM f_read_file1                                             *
*---------------------------------------------------------------------*
* Routine for reading file and transfered to internal table           *
*---------------------------------------------------------------------*
* INPUT :
*  - p_filedir : file directory
*  - p_filename : file name
* OUTPUT :
*  - lines are kept in itabline
*---------------------------------------------------------------------*

FORM f_read_file1 USING p_filedir TYPE c p_filename TYPE c.

  DATA : l_filename(125) TYPE c.

  CLEAR itabline. REFRESH itabline.
  CONCATENATE p_filedir '/' p_filename INTO l_filename.
  OPEN DATASET l_filename FOR INPUT IN text mode ENCODING DEFAULT.
  DO.
    READ DATASET l_filename INTO wa_itabline.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND wa_itabline TO itabline.
  ENDDO.
  CLOSE DATASET l_filename.

  GET REFERENCE OF gt_po_header INTO gs_result_xml-value.
  gs_result_xml-name = 'IPO_HEADER'.
  APPEND gs_result_xml TO gt_result_xml.

  GET REFERENCE OF gt_po_detail INTO gs_result_xml-value.
  gs_result_xml-name = 'IPO_DETAIL'.
  APPEND gs_result_xml TO gt_result_xml.

  GET REFERENCE OF gt_po_footer INTO gs_result_xml-value.
  gs_result_xml-name = 'IPO_FOOTER'.
  APPEND gs_result_xml TO gt_result_xml.

  TRY.
      CALL TRANSFORMATION zs_upload_b2b_lion
      SOURCE XML itabline
      RESULT (gt_result_xml).

    CATCH cx_root INTO gs_rif_ex.

      gs_var_text = gs_rif_ex->get_text( ).

      IF gs_var_text IS NOT INITIAL.
        PERFORM error_xml USING p_filename.
        l_err       = 'X'.
        l_errheader = 'X'.
      ENDIF.

*      MESSAGE gs_var_text TYPE 'E'.
  ENDTRY.
ENDFORM.                    " F_READ_FILE1

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CONVERT
*&---------------------------------------------------------------------*
FORM f_date_convert  USING    fu_datum
                     CHANGING fc_datum.

  DATA: str1  TYPE string,
        str2  TYPE string,
        str3  TYPE string,
        mnr(2).

  CLEAR: fc_datum.
  SPLIT fu_datum AT '-' INTO: str1 str2 str3.
  CASE str2.
    WHEN 'Jan'.
      mnr  = '01'.
    WHEN 'Feb'.
      mnr  = '02'.
    WHEN 'Mar'.
      mnr  = '03'.
    WHEN 'Apr'.
      mnr  = '04'.
    WHEN 'May'.
      mnr  = '05'.
    WHEN 'Jun'.
      mnr  = '06'.
    WHEN 'Jul'.
      mnr  = '07'.
    WHEN 'Aug'.
      mnr  = '08'.
    WHEN 'Sep'.
      mnr  = '09'.
    WHEN 'Oct'.
      mnr  = '10'.
    WHEN 'Nov'.
      mnr  = '11'.
    WHEN 'Dec'.
      mnr  = '12'.
  ENDCASE.
  CONCATENATE str3 mnr str1 INTO fc_datum.
ENDFORM.                    " F_DATE_CONVERT

*&---------------------------------------------------------------------*
*&      Form  ERROR_XML
*&---------------------------------------------------------------------*
FORM error_xml USING fu_filename.

  CONCATENATE fu_filename 'error XML :' gs_var_text INTO v_mstring
  SEPARATED BY space.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  APPEND i_b2blog.
ENDFORM.                    " ERROR_XML
