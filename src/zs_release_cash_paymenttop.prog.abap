*&---------------------------------------------------------------------*
*&  Include           ZS_RELEASE_CASH_PAYMENTTOP
*&---------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: tvko,
        tvkov,
        tvkbz,
        tvbvk,
        kna1,
        vbuk,
        zghsddt004,
        zghsddt005,
        vbak.


************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_key,
          vbeln LIKE vbuk-vbeln,
        END OF t_key.


TYPES : BEGIN OF t_itab1,
          vkbur     LIKE vbak-vkbur,
          vbeln     LIKE vbak-vbeln,
          kunnr     LIKE vbak-kunnr,
          netwr     LIKE vbak-netwr,
          audat     LIKE vbak-audat,
          lifsk     LIKE vbak-lifsk,
          name1     LIKE kna1-name1,
          auth(1),
          usrgroup  LIKE zsauth-usrgroup,
          auart     LIKE vbak-auart,
          mini(1),
          bnddt     LIKE vbak-bnddt,
          usrgroup1 LIKE zghsddt005-name1,
          usrgroup2 LIKE zghsddt005-name2,
          zdept(1),
          ihrez_e   LIKE vbkd-ihrez_e,
          abrvw     LIKE vbak-abrvw,
          bstnk     LIKE vbak-bstnk,
          kzwi5     TYPE vbap-kzwi5,
          budat     TYPE zfidt010-budat,
        END OF t_itab1.

TYPES : BEGIN OF t_tmp,
          vkbur     LIKE vbak-vkbur,
          vbeln     LIKE vbak-vbeln,
          posnr     LIKE vbap-posnr,
          kunnr     LIKE vbak-kunnr,
          netwr     LIKE vbak-netwr,
          audat     LIKE vbak-audat,
          lifsk     LIKE vbak-lifsk,
          name1     LIKE kna1-name1,
          auth(1),
          usrgroup  LIKE zsauth-usrgroup,
          auart     LIKE vbak-auart,
          mini(1),
          bnddt     LIKE vbak-bnddt,
          usrgroup1 LIKE zghsddt005-name1,
          usrgroup2 LIKE zghsddt005-name2,
          zdept(1),
          ihrez_e   LIKE vbkd-ihrez_e,
          abrvw     LIKE vbak-abrvw,
          bstnk     LIKE vbak-bstnk,
          kzwi5     TYPE vbap-kzwi5,
          budat     TYPE zfidt010-budat,
        END OF t_tmp.

************************************************************************
* VARIABLES                                                            *
************************************************************************

DATA: va_mark(1),
      c1         TYPE i,
      c2         TYPE i,
      c3         TYPE i,
      c4         TYPE i,
      w1         TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
      w5         TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
      w9         TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
      w13        TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
      w17        TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
      w20        TYPE i,  w17a  TYPE i,
      w21        TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
      w25        TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
      w29        TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
      w33        TYPE i,  w34   TYPE i,  w35   TYPE i.

DATA: i_itab1       TYPE t_itab1 OCCURS 0 WITH HEADER LINE,
      i_tmp         TYPE t_tmp OCCURS 0 WITH HEADER LINE,
      i_itab1_temp  TYPE t_itab1 OCCURS 0 WITH HEADER LINE,
      wa_itab1_temp TYPE t_itab1,
      i_itab3       TYPE t_itab1 OCCURS 0,
      i_itab2       TYPE t_itab1 OCCURS 0,
      wa_itab1      TYPE t_itab1,
      wa_itab3      TYPE t_itab1,
      i_key         TYPE t_key OCCURS 0,
      wa_key        TYPE t_key,

      va_usrgroup   LIKE zscl_user-usrgroup,
      va_netwr      LIKE zsmov-netwr,
      va_netwr1     LIKE zsmov-netwr,
      va_netwr2     LIKE zsmov-netwr,
      va_vbeln      LIKE vbak-vbeln,
      va_dept       LIKE zghsddt004-zdept,
      va_dept1      LIKE zghsddt004-zdept,
      wa_zghsddt005 LIKE zghsddt005.
"va_remark(25).

DATA: va_value         LIKE vbak-vbeln,
      va_fieldname(30).
DATA  panjang TYPE i..

DATA : gt_usrgrp   TYPE STANDARD TABLE OF usgrp_user.

************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE <%_list>.
**
DATA:  va_list TYPE slist_listline.

RANGES: ra_kkber FOR knvv-kkber.
DATA: gt_zsmapping_soff TYPE zsmapping_soff OCCURS 0,
      gs_zsmapping_soff TYPE zsmapping_soff.

DATA: gt_zghsddt004 TYPE zghsddt004 OCCURS 0,
      gs_zghsddt004 TYPE zghsddt004.
DATA: gt_zghsddt005 TYPE zghsddt005 OCCURS 0,
      gs_zghsddt005 TYPE zghsddt005.

DATA: gt_usgrp_user TYPE usgrp_user OCCURS 0,
      gs_usgrp_user TYPE usgrp_user.
