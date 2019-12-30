$PBExportHeader$u_trans_app.sru
forward
global type u_trans_app from u_trans_base
end type
end forward

global type u_trans_app from u_trans_base
end type
global u_trans_app u_trans_app

type prototypes
//사용자 암호화
subroutine PASSWORD_DESENCRYPT(string P_INPUT_PASS,ref string P_OUT_PASS,ref double P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PASSWORD_DESENCRYPT~""


//위약금 발생
subroutine B1CALCPENALTY(string P_CUSTOMERID,string P_CONTRACTSEQ,datetime P_TERMDT,string P_ORDERNO,string P_USER,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1CALCPENALTY~""

//연체자관리
subroutine E01_CALC_OVERDUEM(string P_STDDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"E01_CALC_OVERDUEM~""
subroutine E01_SELECT_DLY(long P_DELAYM_FR,long P_DELAYM_TO,string P_PGM_ID,string P_USER_ID,string P_STDMONTH,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"E01_SELECT_DLY~""
//연체자관리-new 2011.04.25
subroutine E01_CALC_OVERDUEM_BYSVC(string P_STDDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"E01_CALC_OVERDUEM_BYSVC~""
subroutine E01_SELECT_DLY_BYSVC(long P_DELAYM_FR,long P_DELAYM_TO,string P_PGM_ID,string P_USER_ID,string P_STDMONTH,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"E01_SELECT_DLY_BYSVC~""

//대리점
subroutine B2CRT_REGCOMMISSION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRT_REGCOMMISSION~""
subroutine B2CRT_SALECOMMISSION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRT_SALECOMMISSION~""
subroutine B2CRTPARTNERREQDTL(string P_COMMDT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRTPARTNERREQDTL~""
subroutine B2CRT_SALECOMMISSIONPRE(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRT_SALECOMMISSIONPRE~""
subroutine B2CRT_MAINTAINCOMMISSION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRT_SALECOMMISSIONPRE~""
//대리점 
//대리점move
subroutine B2PAYID_MOVEPARTNER(string P_PAYID,string P_REG_PARTNER,string P_SALE_PARTNER,string P_MAIN_PARTNER,string P_PARTNER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2PAYID_MOVEPARTNER~""

//비정기할인대상자생성 
subroutine B3W_REG_CRT_DISCOUNT_CUSTOMER(string P_FGINS,string P_TYPEDIS,string P_TRCOD,datetime P_DTFROM,datetime P_DTTO,decimal P_DCAMT,decimal P_DCRATE,long P_SEQNO,string P_USERID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B3W_REG_CRT_DISCOUNT_CUSTOMER~""

//선불제CDR Append
subroutine B1APPENDPRE_BILCDR(string P_YYYYMMDD_TO,string P_CARRIERFLAG,string P_CARRIERID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1APPENDPRE_BILCDR~""

//일자별CDR Append post_bilcdr&요금재계산
subroutine B5APPENDPOST_BILCDR(string P_YYYYMMDD_TO,string P_CARRIERFLAG,string P_CARRIERID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5APPENDPOST_BILCDR~""
subroutine P2APPENDPRE_BILCDR(string P_YYYYMMDD_TO,string P_CARRIERFLAG,string P_CARRIERID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"P2APPENDPRE_BILCDR~""

subroutine B5CALCPOST_BILCDR(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_VALIDKEY,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCPOST_BILCDR~""

//청구작업
subroutine B5INVSTART(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5INVSTART~""
subroutine B5ITEMSALE_M(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_M~""
//khpark modiry 정액상품rating  argument 추가 string P_STR_NO(payid)
subroutine B5ITEMSALE_M_V21(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_M~""

   //선불제기본료추가 2005.03.18
subroutine B5ITEMSALE_M_PRE(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_M_PRE~""
subroutine B5ITEMSALE_POSTV(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_POSTV~""
subroutine B5W_PRC_DISCOUNT_CUSTOMER(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5W_PRC_DISCOUNT_CUSTOMER~""
subroutine B5CALCITEMDISCOUNT(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCITEMDISCOUNT~""
subroutine B5CALCINVDISCOUNT(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCINVDISCOUNT~""
subroutine B5DELAYFEE(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5DELAYFEE~""
subroutine B5MINUSINPUT(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5MINUSINPUT~""
subroutine B5CALCTAX(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTAX~""
subroutine B5PREPAYMENT(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYMENT~""
subroutine B5CALCTRUNK(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTRUNK~""
subroutine B5REQAMTINFO(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQAMTINFO~""
subroutine B5INVEND(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5INVEND~""
subroutine B5ITEMSALECLOSE(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref string P_REQNUM_FR,ref string P_REQNUM_TO,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALECLOSE~""

//청구절차취소메뉴
subroutine B5ITEMSALE_MCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_MCAN~""
subroutine B5ITEMSALE_MREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_MREP~""
subroutine B5ITEMSALE_MCAN_V21(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_MCAN~""
subroutine B5ITEMSALE_MREP_V21(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_MREP~""

  //선불제기본료취소/재처리 추가 2005.03.18
subroutine B5ITEMSALE_M_PRECAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_M_PRECAN~""
subroutine B5ITEMSALE_M_PREREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_M_PREREP~""
subroutine B5ITEMSALE_POSTVCAN(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_POSTVCAN~""
subroutine B5ITEMSALE_POSTVREP(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_POSTVREP~""
subroutine B5CALCITEMDISCOUNTCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCITEMDISCOUNTCAN~""
subroutine B5CALCITEMDISCOUNTREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCITEMDISCOUNTREP~""
subroutine B5ITEMSALECLOSECAN(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref string P_REQNUM_FR,ref string P_REQNUM_TO,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALECLOSECAN~""
subroutine B5ITEMSALECLOSEREP(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref string P_REQNUM_FR,ref string P_REQNUM_TO,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALECLOSEREP~""
subroutine B5CALCINVDISCOUNTCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCINVDISCOUNTCAN~""
subroutine B5CALCINVDISCOUNTREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCINVDISCOUNTREP~""
subroutine B5DELAYFEECAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5DELAYFEECAN~""
subroutine B5DELAYFEEREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5DELAYFEEREP~""
subroutine B5MINUSINPUTCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5MINUSINPUTCAN~""
subroutine B5MINUSINPUTREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5MINUSINPUTREP~""
subroutine B5CALCTAXCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTAXCAN~""
subroutine B5CALCTAXREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTAXREP~""
subroutine B5PREPAYMENTCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYMENTCAN~""
subroutine B5PREPAYMENTREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYMENTREP~""
subroutine B5CALCTRUNKCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTRUNKCAN~""
subroutine B5CALCTRUNKREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCTRUNKREP~""
subroutine B5REQAMTINFOCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQAMTINFOCAN~""
subroutine B5REQAMTINFOREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQAMTINFOREP~""
//부가세계산 계산/취소/재처리  2019/05/01부터 적용
//subroutine b5CalcVat(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCVAT~""
//subroutine b5CalcVatCan(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCVATCAN~""
//subroutine b5CalcVatRep(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCVATREP~""
subroutine B5CALC_VAT_UPDATE(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALC_VAT_UPDATE~""
subroutine B5CALC_VAT_CAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALC_VAT_CAN~""
subroutine B5CALC_VAT_UPDATE_REP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALC_VAT_UPDATE_REP~""



//HotSAMS 프로시저
subroutine HOTCLEAR(string P_PAYID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCLEAR~""
subroutine HOTCALCINVDISCOUNT(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCALCINVDISCOUNT~""
subroutine HOTCALCITEMDISCOUNT(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCALCITEMDISCOUNT~""
subroutine HOTCALCTAX(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCALCTAX~""
subroutine HOTCALCTRUNK(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCALCTRUNK~""
subroutine HOTDELAYFEE(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTDELAYFEE~""
subroutine HOTDISCOUNT_CUSTOMER(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTDISCOUNT_CUSTOMER~""
subroutine HOTITEMSALE_M(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_M~""
subroutine HOTITEMSALE_POSTV(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_POSTV~""
subroutine HOTMINUSINPUT(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTMINUSINPUT~""
subroutine HOTSALECLOSE(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTSALECLOSE~""
subroutine HOTAPPENDPOST_BILCDR_V2(string P_PAYID,string P_YYYYMMDD,string P_USERID,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTAPPENDPOST_BILCDR_V2~""

//카드Batch승인파일생성
subroutine B5SP_CARDTEXT_A0(string P_TRDT,string P_CHARGEDT,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT,ref double P_PRCAMT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5SP_CARDTEXT_A0~""

//입금처리
subroutine B5REQPAY2DTL_NOSEQ(string P_PAYTYPE,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL_NOSEQ~""
subroutine B5PAYCARD(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PAYCARD~""
subroutine B5PAYGIRO(ref double P_SUMAMT,ref double P_SUMAMT_ERR,ref double P_PRCCOUNT_ERR,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PAYGIRO~""
subroutine B7GIROREQPAY(string P_PAYTYPE,string P_TRCOD,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B7GIROREQPAY~""
subroutine B7CMSREQPAY(string P_FILENM,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B7CMSREQPAY~""
subroutine B7CARDTEXT(string P_CHARGEDT,string P_TRDT,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B7CARDTEXT~""
subroutine B7CARDREQPAY(long P_workno,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B7CARDREQPAY~""

//수동입금 반영
//subroutine B5REQPAY2DTL(string P_PAYTYPE,double P_SEQNO,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL~""
//subroutine B5REQPAY2DTL(string P_PAYTYPE,string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL~""
//subroutine B5REQPAY2DTL(string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL~""
subroutine B5REQPAY2DTL_PAYID(STRING P_PAYID, string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL_PAYID~""
subroutine B5REQPAY2DTL_PAYID_CANCEL(STRING P_PAYID, string P_EMPID,string P_PGMID,ref long P_RETURN,ref string P_ERRMSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL_PAYID_CANCEL~""

// 할인대상자 취소 
subroutine B5W_PRC_DISCOUNT_CANCLE(string P_CHARGEDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5W_PRC_DISCOUNT_CANCLE~""
subroutine B5W_PRC_DISCOUNT_REDO(string P_CHARGEDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5W_PRC_DISCOUNT_REDO~""

//회선정산
subroutine C1CARRIER_AMOUNT(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_CARRIERFLAG,string P_CARRIERID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"C1CARRIER_AMOUNT~""
subroutine C1CARRIER_AMOUNT_PRE(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_CARRIERFLAG,string P_CARRIERID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"C1CARRIER_AMOUNT_PRE~""
subroutine C1CURR_TMPCDR(string P_CARRIERID,string P_FROMDT,string P_TODT,string P_EMP_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"C1CURR_TMPCDR~""

//선불카드 메출 실적
subroutine APPENDITEMSALE_P_REFILL(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_USER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"APPENDITEMSALE_P_REFILL~""
subroutine APPENDITEMSALE_PRE_BILCDR(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_USER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"APPENDITEMSALE_PRE_BILCDR~""
//선불기본료 매출통계 2005.03.21
subroutine APPENDITEMSALE_PREPAYMENT(string P_YYYYMMDD_TO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"APPENDITEMSALE_PREPAYMENT~""
//선불제 매출통계 2005.04.07
subroutine APPENDITEMSALE_REFILL_PREPAID(string P_YYYYMMDD_TO,string P_USER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"APPENDITEMSALE_REFILL_PREPAID~""

//통계
subroutine S1W_PRC_CRT_CUSTOMERCNT(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1W_PRC_CRT_CUSTOMERCNT~""
subroutine S1W_PRC_VOICE_TONG1(string P_DTFROM,string P_DTTO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1W_PRC_VOICE_TONG1~""
subroutine S1W_PRC_ITEM_TONG(string P_DTSALE,string P_USER,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1W_PRC_ITEM_TONG~""
subroutine S1W_PRC_MWR_REPORT(string P_TODATE,string P_USER,string P_PGM_ID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1W_PRC_MWR_REPORT~""

//선불CDR 이관작업
subroutine TRANSFER_PREBILCDRH(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"TRANSFER_PREBILCDRH~""

//통계불완료 추가
subroutine S2W_PRC_VOICE_TONG2_POST(string P_DTFROM,string P_DTTO,string P_PGM_ID,string P_USER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S2W_PRC_VOICE_TONG2_POST~""
subroutine S2W_PRC_VOICE_TONG2_PRE(string P_DTFROM,string P_DTTO,string P_PGM_ID,string P_USER,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S2W_PRC_VOICE_TONG2_PRE~""

//대리점 한도계산
subroutine B2W_PARTNERBOUND_CAL(string P_FLAG,string P_PARTNER,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2W_PARTNERBOUND_CAL~""

//선/후 일시정지 및 해제
subroutine B1REACTIVE_PREPAYMENT(string P_SVCTYPE,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1REACTIVE_PREPAYMENT~""
subroutine B1SUSPEND_PREPAYMENT(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1SUSPEND_PREPAYMENT~""
subroutine B1SUSPEND_PREPAYMENT_POST(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1SUSPEND_PREPAYMENT_POST~""

//하위대리점 매출수수료 대행정산 - 2005.04.04
subroutine B2CRT_SALE_SUBCOMMISION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B2CRT_SALE_SUBCOMMISION~""

//계약정보파일처리 = 2005.11.10
subroutine CONTRACTUPLOAD_PRC(double P_SEQNO,string P_FILE_CODE,string P_FILENAME,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"CONTRACTUPLOAD_PRC~""

subroutine CUSTOMERCHANGE(double P_ORDERNO,string P_NEWPID,string P_BANNO,string P_REMARK,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"CUSTOMERCHANGE~""
//접속료계산  2005.10.10
subroutine B5ITEMSALE_CONECTIONFEE(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_CONECTIONFEE~""
subroutine B5ITEMSALE_CONECTIONFEEREP(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_CONECTIONFEEREP~""
subroutine B5ITEMSALE_CONECTIONFEECAN(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_CONECTIONFEECAN~""

//2005.11.04 jwlee 고객정보생성
subroutine B1CUSTOMERINFO_REQ(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_PARTNER,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1CUSTOMERINFO_REQ~""

//요금재계산
//ohj add  20051104
subroutine B5CALCPOST_BILCDR_V2(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_VALIDKEY,string P_CUSTOMERID,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCPOST_BILCDR_V2~""
subroutine B5CALCPOST_CDRYYYYMMDD_V2(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5CALCPOST_CDRYYYYMMDD_V2~""
subroutine B5APPENDPOST_BILCDR_V2(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5APPENDPOST_BILCDR_V2~""
subroutine P2APPENDPRE_BILCDR_V2(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"P2APPENDPRE_BILCDR_V2~""
//2005.11.25 실적(선/후)
subroutine S1CDRSUMPOST_CDRSUMMARY_V2(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1CDRSUMPOST_CDRSUMMARY_V2~""
subroutine S1CDRSUMPRE_CDRSUMMARY_V2(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S1CDRSUMPRE_CDRSUMMARY_V2~""

//2005.11.28 홀세일마감 ohj
subroutine WHOLESALE_CLOSEING(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_WHOLESALEFLAG,string P_CUSTOMERID,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"WHOLESALE_CLOSEING~""
subroutine WHOLESALE_CRTITEMSALE(string p_strdtfr,string p_strdtTo, string p_Customerid, long p_RETURN, string p_ERR_MSG, double p_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"WHOLESALE_CRTITEMSALE~""

//2005.12.09 jwlee CDR합산처리 
subroutine B1W_MOVE_RETRY_BILCDR(double P_UNITROWNUM,double P_COMMITROWNUM,string P_YYYYMMDD_TO,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1W_MOVE_RETRY_BILCDR~""

//2005.12.27 ohj 보증금 - 사용금액계산, 워닝처리
subroutine PAYID_DEPOSITUSEAMT(string P_YYYYMMDD,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PAYID_DEPOSITUSEAMT~""
subroutine PAYID_DEPOSITPROCESS(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PAYID_DEPOSITPROCESS~""

//세금계산서 발행(prepayment)
subroutine B5W_PRE_TAXSHEETINFO(string P_TAXISSUEDT,string P_PAYDT,string P_TYPE,string P_USER_ID,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5W_PRE_TAXSHEETINFO~""

//2006.03.11 khpark 세금계산서발행(청구절차처리중) 처리/재처리/취소
subroutine B5REQTAXSHEET_INFO(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQTAXSHEET_INFO~""
subroutine B5REQTAXSHEET_INFOCAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQTAXSHEET_INFOCAN~""
subroutine B5REQTAXSHEET_INFOREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQTAXSHEET_INFOREP~""

//2006.07.06 후불 세금계산서 입금일 업데이트 
subroutine B5W_POST_TAXPAYDT(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5W_POST_TAXPAYDT~""

//위약금 2006.07.13
subroutine B5ITEMSALE_PENALTY(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_PENALTY~""
subroutine B5ITEMSALE_PENALTYCAN(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_PENALTYCAN~""
subroutine B5ITEMSALE_PENALTYREP(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_PENALTYREP~""

//Add SSRT -- 2006-10-24
subroutine B5PREPAYCLOSE(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYCLOSE~""
subroutine B5PREPAYCLOSEREP(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYCLOSEREP~""
subroutine B5PREPAYCLOSECAN(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5PREPAYCLOSECAN~""

//ADD --2006-12-12 v21꺼
//계약별 통화량 마감
subroutine S2POSTCDRSUMMARY_CONTRACT_V21(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S2POSTCDRSUMMARY_CONTRACT_V21~""
subroutine S2PRECDRSUMMARY_CONTRACT_V21(string P_YYYYMMDD_TO,double P_UNITROWNUM,double P_COMMITROWNUM,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"S2PRECDRSUMMARY_CONTRACT_V21~""

//UBS 관련 추가 사항
//2009.03.13  모바일 신규 신청 화면. UBS_w_reg_mobileorder ue_process 이벤트. 
subroutine UBS_REG_MOBILE_CUSTOMER(ref String P_CUSTOMERID, String P_LASTNAME, String P_FIRSTNAME, String P_MIDNAME, String P_BASECOD, String P_BUILDINGNO, String P_ROOMNO, String P_UNIT, String P_HOMEPHONE, String P_DEROSDT, String P_PARTNER, String P_ORDER_TYPE, String P_USERID, String P_PGMID, ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_MOBILE_CUSTOMER~""
subroutine UBS_REG_MOBILE_CONTRACT(String P_CUSTOMERID, ref Long P_CONTRACTSEQ, String P_PHONE_CONTNO, String P_PRICEPLAN, String P_CARD_CONTNO, String P_PHONENUMBER, String P_PARTNER, String P_ORDER_TYPE, String P_USERID, String P_PGMID,  ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_MOBILE_CONTRACT~""
//2009.03.17  모바일 신규 신청 화면. UBS_w_reg_mobileorder ue_process 이벤트. 
subroutine UBS_REG_MOBILE_SVCORDER(String P_CUSTOMERID, String P_PRICEPLAN, ref String P_ORDERNO, String P_CONTRACTSEQ, String P_USERID, String P_PGMID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_MOBILE_SVCORDER~""
subroutine UBS_REG_MOBILE_CONTRACTDET(ref String P_CUSTOMERID, ref String P_CONTRACTSEQ, String P_ORDERNO, String P_ITEMCOD, Date P_BIL_TODT, String P_ORDER_TYPE, String P_USERID, String P_PGMID, ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_MOBILE_CONTRACTDET~""
//2009.03.19  모바일 기기변경 화면. UBS_w_reg_mobilechange ue_process 이벤트. 
subroutine UBS_REG_MOBILE_AD_CHANGE(String P_CURRENT_SEQ, String P_NEW_SEQ, String P_USERID, String P_PGMID, ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_MOBILE_AD_CHANGE~""
//2009.03.19  모바일 신규 신청 수납 화면. UBS_w_pop_mobilepayment ue_process 이벤트. 
subroutine UBS_REG_DAILYPAYMENT (String P_PARTNER, Date P_PAYDT, String P_CUSTOMERID, String P_ITEMCOD, String P_PAYMETHOD, String P_PAYAMT, String P_REMARK, String P_APPROVALNO, String P_EMPID, String P_PGM_ID, long P_PAYCNT, ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_DAILYPAYMENT~""
//2019.05.01 부가세 개발로 ARGUMENT 추가하여 새로 작성
subroutine REG_DAILYPAYMENT (String P_PARTNER, Date P_PAYDT, String P_CUSTOMERID, String P_ITEMCOD, String P_PAYMETHOD, String P_PAYAMT,  String P_TAXAMT, String P_REMARK, Date P_TRDT,  Long p_contractseq, String P_APPROVALNO, String P_EMPID, String P_PGM_ID, long P_PAYCNT, ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"REG_DAILYPAYMENT~""
//2009.04.15  서비스일시정지신청. b1w_reg_svc_suspendorder_b ue_extra_save 이벤트. 
subroutine UBS_REG_SUSPENDORDER (String P_CONTRACTSEQ, ref Long P_ORDERNO, Date P_REQUESTDT, String P_REQ, String P_REMARK, String P_SUSPEND_TYPE, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_SUSPENDORDER~""
//2009.04.16  서비스해소신청. b1w_reg_svc_reactorder_a ue_extra_save 이벤트. 
subroutine UBS_REG_REACTIVEORDER(String P_CONTRACTSEQ, ref Long P_ORDERNO, Date P_REQUESTDT, String P_REQ, String P_REMARK, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_REACTIVEORDER~""
//2009.04.21  서비스해지신청. b1w_reg_svc_termorder_2_v20_sams ue_extra_save 이벤트. 
subroutine UBS_REG_TERMORDER(String P_CONTRACTSEQ, ref Long P_ORDERNO, Date P_REQUESTDT, Date P_ENDDT, String P_REQ, String P_TERMTYPE, String P_PARTNER, String P_REMARK, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_TERMORDER~""
//2009.04.27  청구수납 반영. b5w_reg_mtr_inp_sams
subroutine UBS_REG_REQPAY(String P_PAYID, String P_PAYCOD, String P_SALETRCOD, Date P_PAYDT,    Date P_REQ_TRDT, String P_REMARK, decimal P_TRAMT, Date P_TRANSDT, String P_TRCOD, String P_APPROVALNO, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_REQPAY~""
//2009.04.29  수납취소 처리. b5w_reg_mtr_inp_cancel
subroutine UBS_REG_BILLCANCEL(String P_OLD_APPRNO, ref String P_NEW_APPRNO, String P_OPERATOR, String P_REMARK, String P_EMPID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_BILLCANCEL~""
//2009.04.27  선수금환불 반영. ubs_w_reg_prepayrefund
//2015.03.23  지정품목 추가
subroutine UBS_REG_PREPAYDET(String P_PARTNER, Date P_PAYDT, String P_CUSTOMERID, String P_ITEMCOD, String P_PAYMETHOD, Decimal P_PAYAMT, String P_REMARK, String P_APPROVALNO, String P_OPERATOR, String P_EMPID, String P_PGM_ID, String P_SUB_ITEMCOD, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_PREPAYDET~""
//subroutine UBS_REG_PREPAYDET(String P_PARTNER, Date P_PAYDT, String P_CUSTOMERID, String P_ITEMCOD, String P_PAYMETHOD, Decimal P_PAYAMT, String P_REMARK, String P_APPROVALNO, String P_OPERATOR, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_PREPAYDET~""
//2009.05.05  그룹물품등록. ubs_w_reg_groupadin
subroutine UBS_REG_GROUPIN(String P_ACTION, String P_ADTYPE, String P_MV_PARTNER, String P_FR_PARTNER, Long P_SEQNO, Long P_AMOUNT, String P_MAKER, String P_ENTSTORE, Date P_WORKDT, String P_REMARK, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_GROUPIN~""
//2009.05.06  서비스 신규개통처리. ubs_w_reg_activation
subroutine UBS_REG_ACTIVATION(Long P_ORDERNO, ref Long ll_contractseq, String P_REMARK, DATE P_ACTIVEDT, DATE P_BILFROMDT, String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_REG_ACTIVATION~""
//2009.05.06  장비인증 팝업. ubs_w_pop_equipvalid 
subroutine UBS_PROVISIONNING(Long P_ORDERNO, String P_ACTION_CDD, Long P_EQUIPSEQ, String P_TEL_NUM,    String P_EMPID, String P_PGM_ID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_PROVISIONNING~""

//Hot Bill - 계약별 프로시저 추가!
subroutine HOTITEMSALE_M_CONT(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_M_CONT~""
subroutine HOTITEMSALE_M_CONT_ori(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_M_CONT_ori~""

subroutine HOTAPPENDPOST_BILCDR_V2_CONT(string P_PAYID,string P_YYYYMMDD,string P_USERID,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTAPPENDPOST_BILCDR_V2_CONT~""
subroutine HOTITEMSALE_POSTV_CONT(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_POSTV_CONT~""
subroutine HOTDISCOUNT_CUSTOMER_CONT(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTDISCOUNT_CUSTOMER_CONT~""
subroutine HOTSALECLOSE_CONT(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTSALECLOSE_CONT~""
subroutine HOTCALCVAT(string P_PAYID,string P_TERMDT,string P_USER_ID,string P_PGM_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTCALCVAT~""


//CDR Report 관련. 2010.03.26
subroutine APPENDPOST_BILCDR_CUST(string P_PAYID, long P_CONTRACTSEQ, string P_YYYYMMDD, string P_USERID, string P_PGMID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"APPENDPOST_BILCDR_CUST~""
subroutine CALC_CDRRETRIEVE(string P_PAYID, long P_CONTRACTSEQ, DATE P_USEDDT_FR, DATE P_USEDDT_TO, string P_PGMID, string P_USERID, ref long P_RETURN, ref string P_ERR_MSG, ref long P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"CALC_CDRRETRIEVE~""

//2010.07.13 AUTOPAY CANCEL 프로시저 - JHCHOI
subroutine B5REQPAY2DTL_PAYID_AP_CANCEL(string P_PAYID, long P_SEQNO, string P_REASON, string P_USERID, string P_PGMID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5REQPAY2DTL_PAYID_AP_CANCEL~""

//2011.03.05 CDR 재처리 관련 프로시저 - JHCHOI
subroutine UBS_PRC_CDR_RECONNECTION(string P_CHECK, string P_CUSTOMERID, long P_CONTRACTSEQ, long P_NEW_CONTRACTSEQ, string P_VALIDKEY, string P_CALLDT_FR, string P_CALLDT_TO, string P_EMPID, string P_PGMID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_PRC_CDR_RECONNECTION~""
subroutine UBS_PRC_CDR_REPROCESS(string P_CUSTOMERID, long P_CONTRACTSEQ, string P_CALLDT_FR, string P_CALLDT_TO, string P_EMPID, string P_PGMID, ref long P_RETURN, ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"UBS_PRC_CDR_REPROCESS~""

//2012.01.04 AAFES Settlement Summary 프로시져 - kem
subroutine PRC_AAFES_SUMREPORT_DATA(string P_WORKDT,string P_EMP_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PRC_AAFES_SUMREPORT_DATA~""
//2017.01.31 AAFES Settlement Summary 프로시져 - CATV 추가
subroutine PRC_AAFES_SUMREPORT_DATA_CATV(string P_WORKDT,string P_EMP_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PRC_AAFES_SUMREPORT_DATA_CATV~""

//2015-03 재과금 청구파일 업로드
subroutine B1W_INV_FILEUPLOAD(double P_WORKNO,string P_TRDT,string P_FILEFORMCD,string P_CUSTOMERID,string P_CUSTOMERNM,string P_USER,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1W_INV_FILEUPLOAD~""

//2015-03 청구절차추가 : 재과금정액상품 Rating 추가
subroutine B5ITEMSALE_UPLOAD(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_UPLOAD~""
subroutine B5ITEMSALE_UPLOADCAN(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_UPLOADCAN~""
subroutine B5ITEMSALE_UPLOADREP(string P_CHARGEDT,string P_STR_NO,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B5ITEMSALE_UPLOADREP~""

//2015-03-31 - Hot Bill - 위약금 프로시저 추가!
subroutine HOTITEMSALE_PENALTY(string P_PAYID,string P_TERMDT,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"HOTITEMSALE_PENALTY~""

//2015-03-16 - SHOP 서비스신청 처리 - lys
subroutine B1W_PRC_SVC_REQ_MST(Long p_reqno, String p_req_code, String p_operator, ref double P_RETURN,ref string P_ERR_MSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1W_PRC_SVC_REQ_MST~""

//2015-03-29 - 개통처비교레포트 - 비교자료 생성 - lys
subroutine B1W_PRC_DATA_COMPARE_MAIN(string p_agent_cd, Date p_reqdt, Long p_seq, String p_operator, ref long p_retcode,ref string p_retmsg) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"B1W_PRC_DATA_COMPARE_MAIN~""


//2016-10-20 - 해지DB 이관처리
subroutine PRC_CUST_TRANSFER(long P_WORKNO,string P_WORK_GUBUN,string P_STATUS,date P_TARGET_FR,date P_TARGET_TO, date P_WORKDT_FR,date P_WORKDT_TO ,string P_EMPID,ref long P_RETURN,ref string P_ERRMSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PRC_CUST_TRANSFER~""
subroutine PRC_CUST_PROCESS(long P_WORKNO,string P_WORK_GUBUN,string P_STATUS,date P_TARGET_FR,date P_TARGET_TO, date P_WORKDT_FR,date P_WORKDT_TO ,string P_EMPID,ref long P_RETURN,ref string P_ERRMSG) RPCFUNC ALIAS FOR "~"BLBLAPP~".~"PRC_CUST_PROCESS~""

            
end prototypes
on u_trans_app.create
call super::create
end on

on u_trans_app.destroy
call super::destroy
end on

