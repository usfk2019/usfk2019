$PBExportHeader$ubs_w_prt_aafes_report.srw
$PBExportComments$[jhchoi] 서비스별 가입자수 관리 - 2009.07.08
forward
global type ubs_w_prt_aafes_report from w_a_print
end type
type dw_file from datawindow within ubs_w_prt_aafes_report
end type
type dw_temp from datawindow within ubs_w_prt_aafes_report
end type
type gb_2 from groupbox within ubs_w_prt_aafes_report
end type
end forward

global type ubs_w_prt_aafes_report from w_a_print
integer width = 3346
integer height = 1992
event ue_create ( )
dw_file dw_file
dw_temp dw_temp
gb_2 gb_2
end type
global ubs_w_prt_aafes_report ubs_w_prt_aafes_report

type variables
INTEGER	ii_maxnum, &
			ii_time =  21 //Time의 간격수
String	is_time[],	is_file
			
			
end variables

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_margin = True
end event

on ubs_w_prt_aafes_report.create
int iCurrent
call super::create
this.dw_file=create dw_file
this.dw_temp=create dw_temp
this.gb_2=create gb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
this.Control[iCurrent+2]=this.dw_temp
this.Control[iCurrent+3]=this.gb_2
end on

on ubs_w_prt_aafes_report.destroy
call super::destroy
destroy(this.dw_file)
destroy(this.dw_temp)
destroy(this.gb_2)
end on

event ue_ok;// 화면 리셋
dw_list.Reset()

// Local Variable Define
STRING	ls_option,			ls_cutoff,			ls_svctype,			ls_regtype,			ls_vendor,	&
			ls_sql,				ls_prt_frdt,		ls_ret_frdt,		ls_prt_cutoff
LONG		ll_row

dw_cond.AcceptText()

// Get Data From dw_cond
ls_option		= dw_cond.Object.option[1]
ls_cutoff		= string(dw_cond.Object.cutoff_dt[1], 'yyyymmdd')
ls_svctype		= dw_cond.Object.svc_type[1]
ls_regtype		= dw_cond.Object.regtype[1]
ls_vendor		= dw_cond.Object.vendor[1]

//Null Check
IF IsNull(ls_option)	 THEN ls_option	= ""
IF IsNull(ls_cutoff)  THEN ls_cutoff	= ""
IF IsNull(ls_svctype) THEN ls_svctype	= ""
IF IsNull(ls_regtype) THEN ls_regtype	= ""
IF IsNull(ls_vendor)  THEN ls_vendor	= ""
		
//Retrieve. Key Value Check
IF ls_option = "" THEN
	f_msg_info(200, title, "Option")
	dw_cond.SetFocus()
	dw_cond.SetColumn("option")
	RETURN
END IF

IF ls_cutoff = "" THEN
	f_msg_info(200, title, "cutoff")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cutoff_dt")
	RETURN
END IF

//cutoff 기간 뽑기...

SELECT TO_CHAR(MAX(CUTOFF_DT) + 1, 'YYYYMMDD')
INTO   :ls_ret_frdt
FROM   CUTOFF
WHERE  CUTOFF_DT < TO_DATE(:ls_cutoff, 'YYYYMMDD');

ls_prt_cutoff = MidA(ls_cutoff, 5, 2) + '-' + MidA(ls_cutoff, 7, 2) + '-' + MidA(ls_cutoff, 1, 4)
ls_prt_frdt   = MidA(ls_ret_frdt, 5, 2) + '-' + MidA(ls_ret_frdt, 7, 2) + '-' + MidA(ls_ret_frdt, 1, 4)

IF ls_option = '1' THEN
	ls_sql = "SELECT X.SVC_TYPE, X.VENDOR_CODE, X.EXCHNO, X.ANX, " +&
				"		  '" + ls_prt_cutoff + "' as CUTOFF_DT, " +&
				"		  '" + ls_prt_frdt + " - " + ls_prt_cutoff + "' as SALES_DATE, " +&
				"       SUM(DECODE(X.PAYMETHOD, '101', X.PAYAMT, '102', X.PAYAMT, 0)) AS GROSS_AMT, " +&
				"       SUM(DECODE(X.PAYMETHOD, '103', X.PAYAMT, '104', X.PAYAMT, 0)) AS MILSTAR_AMT, " +&
				"       0 AS BULK_AMT, " +&
				"       SUM(DECODE(X.PAYMETHOD, '105', X.PAYAMT, '107', X.PAYAMT, 0)) AS OTHER_AMT, " +&
				"       SUM(X.PAYAMT) AS TOTAL_AMT " +&
				"FROM ( SELECT  A.BASECOD, A.PAYID, A.ITEMCOD, A.REGCOD, B.KEYNUM, " +&
				"			       SUBSTR(C.INDEXDESC, 1, 4) AS EXCHNO,	" +&
				"			       SUBSTR(C.INDEXDESC, 6, 4) AS VENDOR_CODE, " +&
				"			       SUBSTR(C.INDEXDESC, 11, 2) AS ANX, " +&
				"			       C.INDEXDESC, " +&
				"			       A.PAYAMT, " +&
				"		 			 B.REGTYPE, " +&
				"		 			 A.PAYMETHOD, " +&
				"		 			 B.SVC_TYPE  " +&
				"		  FROM    DAILYPAYMENT A, REGCODMST B, SHOP_REGIDX C " +&
				"		  WHERE  A.PAYDT >= TO_DATE('" + ls_ret_frdt + "', 'YYYYMMDD') "  +&
				"		  AND    A.PAYDT <= TO_DATE('" + ls_cutoff + "', 'YYYYMMDD') " +&
				"		  AND    A.SHOPID NOT IN ('000SE', 'A100013', 'A100015') " +&
				"		  AND    A.REGCOD = B.REGCOD "
	IF ls_svctype <> "" THEN
		ls_sql = ls_sql + " AND B.SVC_TYPE = '" + ls_svctype + "' "
	END IF
	
	ls_sql = ls_sql + " AND    A.SHOPID = C.SHOPID " +&
							" AND    A.REGCOD = C.REGCOD " +&
							" UNION ALL " +&
							" SELECT A.CAMP, A.PAYID, A.ITEMCOD, A.REGCOD, TO_NUMBER(A.KEY_NO), " +&
							"        A.EXCHNO, A.VENDOR_CODE, A.ANX, " +&
							"        A.EXCHNO||'-'||A.VENDOR_CODE||'-'||A.ANX AS INDEXDESC, " +&
							"        A.AMOUNT, " +&
							"        B.REGTYPE, " +&
       					"			'101' AS PAYMETHOD, " +&
							"        B.SVC_TYPE " +&
							"FROM    AAFES_DATA A, REGCODMST B " +&
							"WHERE   A.CUTOFF_DT = TO_DATE('" + ls_cutoff + "', 'YYYYMMDD') " +&
							"AND     A.REGCOD = B.REGCOD " 
	IF ls_svctype <> "" THEN
		ls_sql = ls_sql + " AND B.SVC_TYPE = '" + ls_svctype + "' ) X "
	ELSE
		ls_sql = ls_sql + " ) X "
	END IF

	IF ls_vendor <> "" THEN
		ls_sql = ls_sql + " WHERE X.VENDOR_CODE = '" + ls_vendor + "' " +&
								" GROUP BY X.SVC_TYPE, X.VENDOR_CODE, X.EXCHNO, X.ANX "
	ELSE
		ls_sql = ls_sql + " GROUP BY X.SVC_TYPE, X.VENDOR_CODE, X.EXCHNO, X.ANX "
	END IF
ELSE
	ls_sql = "SELECT X.REGTYPE, REPLACE(X.INDEXDESC, '-', '') AS INSEXDESC, " +&
				"		  '" + ls_prt_cutoff + "' as CUTOFF_DT, " +&
				"		  '" + ls_prt_frdt + " - " + ls_prt_cutoff + "' as SALES_DATE, " +&
				"       SUM(DECODE(X.PAYMETHOD, '101', X.PAYAMT, '102', X.PAYAMT, 0)) AS GROSS_AMT, " +&
				"       SUM(DECODE(X.PAYMETHOD, '103', X.PAYAMT, '104', X.PAYAMT, 0)) AS MILSTAR_AMT, " +&
				"       0 AS BULK_AMT, " +&
				"       SUM(DECODE(X.PAYMETHOD, '105', X.PAYAMT, '107', X.PAYAMT, 0)) AS OTHER_AMT, " +&
				"       SUM(X.PAYAMT) AS TOTAL_AMT " +&		
				"FROM ( SELECT  A.BASECOD, A.PAYID, A.ITEMCOD, A.REGCOD, B.KEYNUM, " +&
				"			       SUBSTR(C.INDEXDESC, 1, 4) AS EXCHNO,	" +&
				"			       SUBSTR(C.INDEXDESC, 6, 4) AS VENDOR_CODE, " +&
				"			       SUBSTR(C.INDEXDESC, 11, 2) AS ANX, " +&
				"			       C.INDEXDESC, " +&
				"			       A.PAYAMT, " +&
				"		 			 B.REGTYPE, " +&
				"		 			 A.PAYMETHOD, " +&
				"		 			 B.SVC_TYPE  " +&
				"		  FROM    DAILYPAYMENT A, REGCODMST B, SHOP_REGIDX C " +&
				"		  WHERE  A.PAYDT >= TO_DATE('" + ls_ret_frdt + "', 'YYYYMMDD') "  +&
				"		  AND    A.PAYDT <= TO_DATE('" + ls_cutoff + "', 'YYYYMMDD') " +&
				"		  AND    A.SHOPID NOT IN ('000SE', 'A100013', 'A100015') " +&
				"		  AND    A.REGCOD = B.REGCOD "				
	IF ls_regtype <> "" THEN
		ls_sql = ls_sql + " AND B.REGTYPE = '" + ls_regtype + "' "
	END IF
	ls_sql = ls_sql + " AND    A.SHOPID = C.SHOPID " +&
							" AND    A.REGCOD = C.REGCOD " +&
							" UNION ALL " +&
							" SELECT A.CAMP, A.PAYID, A.ITEMCOD, A.REGCOD, TO_NUMBER(A.KEY_NO), " +&
							"        A.EXCHNO, A.VENDOR_CODE, A.ANX, " +&
							"        A.EXCHNO||'-'||A.VENDOR_CODE||'-'||A.ANX AS INDEXDESC, " +&
							"        A.AMOUNT, " +&
							"        B.REGTYPE, " +&
       					"			'101' AS PAYMETHOD, " +&
							"        B.SVC_TYPE " +&
							"FROM    AAFES_DATA A, REGCODMST B " +&
							"WHERE   A.CUTOFF_DT = TO_DATE('" + ls_cutoff + "', 'YYYYMMDD') " +&
							"AND     A.REGCOD = B.REGCOD " 
	IF ls_regtype <> "" THEN
		ls_sql = ls_sql + " AND B.REGTYPE = '" + ls_regtype + "' ) X " +&
								" GROUP BY X.REGTYPE, X.INDEXDESC "
	ELSE
		ls_sql = ls_sql + " ) X " +&
								" GROUP BY X.REGTYPE, X.INDEXDESC "
	END IF
END IF	
	
dw_list.SetSQLSelect(ls_sql)
ll_row =dw_list.Retrieve()	

If ll_row < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return	
End If  

// 출력 및 여백 조정 
dw_list.Object.DataWindow.Print.Preview = 'Yes'

IF ib_margin THEN
	dw_list.object.datawindow.print.margin.Top = 0
   dw_list.object.datawindow.print.margin.Bottom = 0
   dw_list.object.datawindow.print.margin.Left = 0
   dw_list.object.datawindow.print.margin.Right = 0
END IF

RETURN
end event

event open;call super::open;DATE	ld_sysdate

dw_cond.Object.option[1] = '1'

//SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
//FROM   DUAL;
//
//dw_cond.Object.workdt_from[1]	 = ld_sysdate
//dw_cond.Object.workdt_to[1]	 = ld_sysdate
end event

event ue_saveas;datawindow	ldw

ldw = dw_list

f_excel(ldw)

end event

event ue_reset;call super::ue_reset;dw_cond.Object.option[1] = '1'
end event

type dw_cond from w_a_print`dw_cond within ubs_w_prt_aafes_report
integer x = 73
integer y = 40
integer width = 1449
integer height = 320
string dataobject = "ubs_dw_prt_aafes_report_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;////Help Window
////Customer ID help
//This.is_help_win[1] = "b1w_hlp_customerm"
//This.idwo_help_col[1] = dw_cond.object.customerid
//This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String	ls_filter
INT		li_rc,			li_exist
DataWindowChild ldwc_vendor

Choose Case dwo.name
	Case "option"
		IF data = '1' THEN
			dw_list.DataObject = "ubs_dw_prt_aafes_report_det1"
			dw_list.SetTransObject(SQLCA)	
		ELSE
			dw_list.DataObject = "ubs_dw_prt_aafes_report_det2"
			dw_list.SetTransObject(SQLCA)	
		END IF			
		
	Case "svc_type"
		
		li_rc = dw_cond.GetChild("vendor", ldwc_vendor)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		This.Object.vendor[row] = ""
		
		ls_filter = "svc_type = '" + data + "' "
		
		ldwc_vendor.SetTransObject(SQLCA)
		li_exist =ldwc_vendor.Retrieve()
		ldwc_vendor.SetFilter(ls_filter)			//Filter정함
		ldwc_vendor.Filter()
		
		If li_exist < 0 Then 				
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If  		
End Choose

Return 0 
end event

type p_ok from w_a_print`p_ok within ubs_w_prt_aafes_report
integer x = 2866
integer y = 40
end type

type p_close from w_a_print`p_close within ubs_w_prt_aafes_report
integer x = 2866
integer y = 180
end type

type dw_list from w_a_print`dw_list within ubs_w_prt_aafes_report
integer y = 400
integer width = 3227
integer height = 1308
string dataobject = "ubs_dw_prt_aafes_report_det1"
end type

type p_1 from w_a_print`p_1 within ubs_w_prt_aafes_report
integer x = 2546
integer y = 1740
end type

type p_2 from w_a_print`p_2 within ubs_w_prt_aafes_report
integer x = 370
integer y = 1740
end type

type p_3 from w_a_print`p_3 within ubs_w_prt_aafes_report
integer x = 2254
integer y = 1740
end type

type p_5 from w_a_print`p_5 within ubs_w_prt_aafes_report
integer x = 1074
integer y = 1740
end type

type p_6 from w_a_print`p_6 within ubs_w_prt_aafes_report
integer x = 1678
integer y = 1740
end type

type p_7 from w_a_print`p_7 within ubs_w_prt_aafes_report
integer x = 1477
integer y = 1740
end type

type p_8 from w_a_print`p_8 within ubs_w_prt_aafes_report
integer x = 1275
integer y = 1740
end type

type p_9 from w_a_print`p_9 within ubs_w_prt_aafes_report
integer x = 667
integer y = 1740
end type

type p_4 from w_a_print`p_4 within ubs_w_prt_aafes_report
integer y = 1756
end type

type gb_1 from w_a_print`gb_1 within ubs_w_prt_aafes_report
boolean visible = false
integer y = 1652
boolean enabled = false
end type

type p_port from w_a_print`p_port within ubs_w_prt_aafes_report
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type p_land from w_a_print`p_land within ubs_w_prt_aafes_report
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type gb_cond from w_a_print`gb_cond within ubs_w_prt_aafes_report
integer width = 1522
integer height = 376
end type

type p_saveas from w_a_print`p_saveas within ubs_w_prt_aafes_report
integer x = 1961
integer y = 1740
end type

type dw_file from datawindow within ubs_w_prt_aafes_report
integer x = 1609
integer y = 68
integer width = 1147
integer height = 268
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_addin_file"
boolean border = false
boolean livescroll = true
end type

event constructor;InsertRow(0)
end event

event buttonclicked;String 	ls_fileName,		ls_fileRow,			pathname,			filename,			ls_save_file,	&
			ls_cutoff,			ls_camp,				ls_payid,			ls_itemcod,			ls_regcod,		&
			ls_key_no,			ls_exchno,			ls_vendor_code,	ls_anx,				ls_pay_gubun, ls_gubun
Long		ll_iqty,				ll_row,				ll_return,			ll_iqty_temp,		ll_xls,			&
			ll_aafes_cnt,		ii
Int		li_fileId,			value,				li_cnt,				li_rtn
DEC{2}	ldc_amt
DATE		ld_cutoff

CHOOSE CASE	dwo.Name
	CASE "search_xls"			//엑셀 파일 찾기
		value = GetFileOpenName("Select File", pathName, fileName, "All Files (*.*),*.*", 'Excel Files (*.xls), *.xls')
		
		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
		OleObject oleExcel 
		
		oleExcel = Create OleObject 
		li_rtn = oleExcel.connecttonewobject("excel.application") 
		
		IF value = 1 THEN
			IF li_rtn = 0 THEN
				oleExcel.WorkBooks.Open(pathName) 
			ELSE
				Messagebox("!", "실패") 
				Destroy oleExcel 
				Return -1
			END IF
		ELSE
			Destroy oleExcel 
			Return -1
		END IF
		
		oleExcel.Application.Visible = False 
		
		ll_xls = PosA(pathName, 'xls')
		ls_save_file = MidA(pathName, 1, ll_xls -2) + '.txt'
		is_file = ls_save_file

		oleExcel.application.workbooks(1).SaveAs(ls_save_file, -4158) 
		oleExcel.application.workbooks(1).Saved = True 
		oleExcel.Application.Quit 
		oleExcel.DisConnectObject() 
		Destroy oleExcel
		
	CASE "xls_load"		//파일처리
		
		ls_cutoff = String(dw_cond.Object.cutoff_dt[1], 'yyyymmdd')
		ld_cutoff = date(dw_cond.Object.cutoff_dt[1])
		
		IF IsNull(ls_cutoff) THEN ls_cutoff = ""

		IF ls_cutoff = "" THEN
			f_msg_info(200, This.Title, "Cutoff")
			dw_cond.SetFocus()
			RETURN 0
		END IF
		
		IF isNull(is_file) THEN is_file = ""
				
		IF is_file = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		SELECT COUNT(*) 
		INTO :ll_aafes_cnt
		FROM   AAFES_DATA
		WHERE  CUSOFF_DT = TO_DATE(:ls_cutoff, 'yyyymmdd');
		
		IF ll_aafes_cnt > 0 THEN
			f_msg_info(200, This.Title, "이미 등록되었습니다.")
			This.SetFocus()
			RETURN 0
		END IF				
		
		ll_return = dw_temp.ImportFile(is_file)
		
		If ll_return < 0 THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If		

		ll_iqty_temp = dw_temp.rowCount()	
		
		FOR ii = 1 TO ll_iqty_temp
			
			ls_camp        = dw_temp.Object.camp       [ii]
			ls_payid       = dw_temp.Object.payid      [ii]
			ls_itemcod     = dw_temp.Object.itemcod    [ii]
			ls_regcod      = dw_temp.Object.regcod     [ii]
			ls_key_no      = dw_temp.Object.key_no     [ii]
//			ls_gubun       = trim(dw_temp.Object.gubun [ii]) // trim 처리
			ldc_amt	      = dw_temp.Object.amount     [ii]
			ls_exchno      = dw_temp.Object.exchno     [ii]
			ls_vendor_code = dw_temp.Object.vendor_code[ii]
			ls_anx         = dw_temp.Object.anx        [ii]
			ls_pay_gubun   = dw_temp.Object.pay_gubun  [ii]
			
			INSERT INTO AAFES_DATA
				( CUTOFF_DT  , 
				  CAMP       , PAYID    , ITEMCOD                   , REGCOD                  , 
				  KEY_NO     , AMOUNT   , EXCHNO                    , VENDOR_CODE             , ANX    ,
				  CRT_USER   , CRTDT    , PGM_ID                    , PAY_GUBUN     )
			VALUES
			   ( TO_DATE(:ls_cutoff, 'yyyymmdd'), 
				  :ls_camp   , :ls_payid, :ls_itemcod               , LPAD(:ls_regcod, 3, '0'),
				  :ls_key_no , :ldc_amt , :ls_exchno                , :ls_vendor_code         , :ls_anx,
				  :gs_user_id, SYSDATE  , :gs_pgm_id[gi_open_win_no], :ls_pay_gubun );
				  
			IF SQLCA.SQLCODE <> 0 THEN
				ROLLBACK;
				f_msg_usr_err(200, Title, "파일처리 실패")
				RETURN 0
			END IF
		NEXT
		
		COMMIT;
		F_MSG_INFO(3000, PARENT.Title, "파일등록")
		
		dw_cond.SetFocus()		
						
END CHOOSE
end event

type dw_temp from datawindow within ubs_w_prt_aafes_report
boolean visible = false
integer x = 2688
integer y = 268
integer width = 411
integer height = 432
integer taborder = 30
boolean bringtotop = true
boolean enabled = false
string dataobject = "ubs_dw_prt_aafes_report_temp"
boolean border = false
boolean livescroll = true
end type

event constructor;	SetTransObject(SQLCA)
end event

type gb_2 from groupbox within ubs_w_prt_aafes_report
integer x = 1595
integer width = 1175
integer height = 376
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

