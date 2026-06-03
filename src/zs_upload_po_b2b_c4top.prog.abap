*&---------------------------------------------------------------------*
*&  Include           ZS_UPLOAD_PO_B2B_C4TOP
*&---------------------------------------------------------------------*
TYPE-POOLS abap.

TABLES : zsh_b2b, zsb2b_errlog.

CONSTANTS : c_interfacein(125)      TYPE c VALUE 'in',
            c_interfaceprocess(125) TYPE c VALUE 'process',
            c_interfacesuccess(125) TYPE c VALUE 'archive',
            c_interfaceerror(125)   TYPE c VALUE 'in',
            c_interfacedelete(125)  TYPE c VALUE 'delete',
            c_logfile(125)          TYPE c VALUE 'log'.

TYPES : BEGIN OF shipto,
          value(100),
          type(100),
        END OF shipto.

TYPES : BEGIN OF plu,
          value(100),
          type(100),
        END OF plu.

TYPES : BEGIN OF description,
          value(100),
          type(100),
        END OF description.

TYPES : BEGIN OF pono,
          value(100),
          type(100),
        END OF pono.

TYPES : BEGIN OF contentowner,
          gln(100),
          pono            TYPE pono,
        END OF contentowner.

TYPES : BEGIN OF tradeitemidentification,
            gtin(100),
            plu           TYPE plu,
            description   TYPE description,
        END OF tradeitemidentification.

TYPES : BEGIN OF multishipmentorder,
          po_no(100),
          gln(100),
          creationdatetime(100),
          versionidentification(100),
          uniquecreatoridentification(100),
          exp_date(100),
          store_id(100),
        END OF multishipmentorder.

TYPES : BEGIN OF orderidentification,
          uniquecreatoridentification(100),
          contentowner  TYPE contentowner,
        END OF orderidentification.

TYPES : BEGIN OF multishipmentorderlineitem,
          requestedquantity(100),
          netprice_curr(100),
          netprice_amount(100),
          netamount_amount(100),
          tradeitemidentification   TYPE tradeitemidentification,
        END OF multishipmentorderlineitem.

TYPES: BEGIN OF ts_po_header,
         po_no(20),
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
         plu(18),
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
         store_id(20),
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
      gt_po_detail      TYPE STANDARD TABLE OF ts_po_detail,
      gt_po_footer      TYPE STANDARD TABLE OF ts_po_footer.

DATA : v_interfacein(125) TYPE c,
       v_interfaceprocess(125) TYPE c,
       v_interfacesuccess(125) TYPE c,
       v_interfaceerror(125) TYPE c,
       v_interfacedelete(125) TYPE c,
       v_logfile(125) TYPE c.

DATA : gt_xml    TYPE abap_trans_resbind_tab,
       gs_xml    TYPE abap_trans_resbind.

DATA : multishipmentorder             TYPE STANDARD TABLE OF multishipmentorder,
       multishipmentorderlineitem     TYPE STANDARD TABLE OF multishipmentorderlineitem,
       orderidentification            TYPE STANDARD TABLE OF orderidentification,
       shipto                         TYPE STANDARD TABLE OF shipto.

DATA : gs_rif_ex        TYPE REF TO cx_root,
       gs_var_text      TYPE string,
       l_err(1),
       l_errheader(1),
       va_totdelete     TYPE n,
       v_error_msg(125) TYPE c VALUE ''.

DATA : BEGIN OF itab OCCURS 0,
         ztext(500),
         index TYPE i,
         zst_err(1),
         zst_delete(1),
         zstatus(1),
       END OF itab.

DATA : BEGIN OF i_matb2b OCCURS 0.
        INCLUDE STRUCTURE zsmat_b2b.
DATA :   bstme  LIKE  zsuom_b2b-bstme,
         poqty  LIKE  zsuom_b2b-poqty,
         doqty  LIKE  zsuom_b2b-doqty,
         vrkme  LIKE  zsuom_b2b-vrkme,
       END OF i_matb2b.

DATA : BEGIN OF i_b2blog OCCURS 0.
        INCLUDE STRUCTURE   zsb2b_errlog.
DATA :   zstatus(1),
       END OF i_b2blog.

DATA : BEGIN OF wa_adrc,
         addrnumber LIKE adrc-addrnumber,
         sort2      LIKE adrc-sort2,
       END OF wa_adrc.

DATA : BEGIN OF wa_cust,
         adrnr  LIKE  kna1-adrnr,
         kunnr  LIKE  kna1-kunnr,
         vkorg  LIKE  knvv-vkorg,
         vtweg  LIKE  knvv-vtweg,
         spart  LIKE  knvv-spart,
         vkbur  LIKE  knvv-vkbur,
       END OF wa_cust.

DATA : i_zsh_b2b  LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
       i_zsd_b2b  LIKE zsd_b2b OCCURS 0 WITH HEADER LINE,
       i_sukses   LIKE zsh_b2b OCCURS 0 WITH HEADER LINE,
       wa_itab    LIKE itab.

DATA : v_delete(1),
       va_totproses     TYPE i,
       va_totrecord     TYPE i,
       v_mstring(255),
       l_fileindex      TYPE i.
