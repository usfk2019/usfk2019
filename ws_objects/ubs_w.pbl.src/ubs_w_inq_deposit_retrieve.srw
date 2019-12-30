$PBExportHeader$ubs_w_inq_deposit_retrieve.srw
$PBExportComments$[jhchoi] 보증금 이력 관리 - 2011.03.05
forward
global type ubs_w_inq_deposit_retrieve from w_a_inq_m
end type
type dw_tmp from u_d_base within ubs_w_inq_deposit_retrieve
end type
type p_1 from u_p_saveas within ubs_w_inq_deposit_retrieve
end type
end forward

global type ubs_w_inq_deposit_retrieve from w_a_inq_m
integer width = 4091
integer height = 2044
event ue_saveas ( )
dw_tmp dw_tmp
p_1 p_1
end type
global ubs_w_inq_deposit_retrieve ubs_w_inq_deposit_retrieve

type variables
String is_format, is_table
Integer ii_cnt

end variables

forward prototypes
public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid)
public function integer wf_cdr_inq_1 (string as_svctype, string as_workdt_fr, string as_customerid, string as_pid)
end prototypes

event ue_saveas;datawindow	ldw

ldw = dw_detail

f_excel(ldw)
end event

public function integer wf_cdr_inq_2 (string as_svctype, string as_workdt_fr, string as_workdt_to, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_flag_group
String ls_format, ls_length_sql
STring ls_ws_sql, ls_ws_sql_1
String ls_svccode, ls_sacnum, ls_priceplan
String ls_stime_fr, ls_stime_to
String ls_pbxno, ls_inid, ls_outid

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0

ls_format = "##0"
For i = 1 To integer(is_format)
   If i = 1 Then ls_format += "."
   ls_format += "0"
Next
dw_detail.Modify("bilamt.Format = '" + ls_format + "'")

/*For i = 1 To li_cnt
	If as_svctype = ls_pre_svctype[i] Then
		ls_type = 'PRE_CDR'
		ls_length_sql = 'LENGTH(TNAME) = 15 '
		Exit;
   End If
Next

For i = 1 To li_cnt_1
	If as_svctype = ls_post_svctype[i] Then
		ls_type = 'POST_CDR'
		ls_length_sql = 'LENGTH(TNAME) = 16 '		
		Exit;
   End If
Next */

IF is_table = 'PRE_CDR' Then
	ls_length_sql = 'LENGTH(TNAME) = 15 '
ElseIF is_table = 'POST_CDR' Then
	ls_length_sql = 'LENGTH(TNAME) = 16 '	
End IF;
	

ls_ws_sql = " SELECT a.customerid, " + &
		"		a.rtime, " + &
		"		a.STIME, " + &
		"		a.ETIME, " + &
		"		a.BILTIME, " + &
		"		a.Stelnum, " + &
		"		a.RTELNUM, " + &
		"		a.BILAMT,  " + &
		"		a.VALIDKEY,  " + &
		"		to_char(a.SEQNO),  " + &
		"		a.CRTDT,  " + &
		"		a.pid, " + &
		"		a.nodeno,  " + &
		"		a.originnum,  " + &
		"		a.areacod,  " + &
		"		a.countrycod,  " + &
		"		a.zoncod,  " + &
		"		b.areanm,  " + &
		"		z.zonnm, "  + &
		"     a.result, " + &
		"     s.svcdesc, " + &
		"     a.inid, " + &
		"     a.outid, " + &
		"     a.flag, " + &
		"     c.flag_group, " + &
		"     a.sacnum, " + &
		"     a.pbxno, " + &
		"     a.priceplan, " + &
		"     a.itemcod, " + &
		"     a.rtelnum2, " + &
		"     a.stelnum2 "
		
ls_customerid = as_customerid
ls_pid        = as_pid
ls_validkey   = Trim(dw_cond.Object.validkey[1])
ls_rtelnum    = Trim(dw_cond.Object.rtelnum[1])
ls_stelnum    = Trim(dw_cond.Object.stelnum[1])
ls_flag_group = Trim(dw_cond.Object.flag_group[1])
ls_svccode    =  Trim(dw_cond.object.svccode[1])
ls_sacnum     = Trim(dw_cond.object.sacnum[1])
ls_priceplan  = Trim(dw_cond.object.priceplan[1])
ls_stime_fr   = Trim(String(dw_cond.object.stime_fr[1],'yyyymmdd'))
ls_stime_to   = Trim(String(dw_cond.object.stime_to[1],'yyyymmdd'))
ls_pbxno      = Trim(dw_cond.object.pbxno[1])
ls_inid       = Trim(dw_cond.object.inid[1])
ls_outid      = Trim(dw_cond.object.outid[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_svccode) Then ls_svccode = ""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""
If Isnull(ls_stime_fr) Then ls_stime_fr = ""
If Isnull(ls_stime_to) Then ls_stime_to = ""
If Isnull(ls_pbxno) Then ls_pbxno = ""
If Isnull(ls_inid) Then ls_inid = ""
If Isnull(ls_outid) Then ls_outid = ""

//기본 Where 문
ls_where = " a.areacod = b.areacod(+) And a.zoncod = z.zoncod(+) And a.svccod = s.svccod(+) And a.flag = c.flag(+)"
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.validkey = '" + ls_validkey + "'"
End if

If as_svctype <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svctype = '" + as_svctype+ "'"
End if

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.customerid = '" + ls_customerid + "'"

End If

If ls_svccode <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccode + "'"
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pid = '" + ls_pid + "'"
End If

If ls_rtelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.rtelnum like '" + ls_rtelnum + "%'"
End if

If ls_stelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stelnum like '" + ls_stelnum + "%'"
End if

If ls_flag_group <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " c.flag_group = '" + ls_flag_group + "'"
End If

If ls_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.sacnum = '" + ls_sacnum + "'"
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "'"
End If

If ls_stime_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(a.stime, 'YYYYMMDD') >= '"+ ls_stime_fr +"'"
End If

If ls_stime_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where	+= "to_char(a.stime, 'YYYYMMDD') <= '"+ ls_stime_to +"'"
End If

If ls_pbxno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pbxno = '" + ls_pbxno + "'"
End If

If ls_inid <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.inid like '" + ls_inid + "%'"
End if

If ls_outid <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.outid like '" + ls_outid + "%'"
End if
	
DECLARE cur_read_cdr_table DYNAMIC CURSOR FOR SQLSA;
DECLARE cur_read_cdr DYNAMIC CURSOR FOR SQLSA;

ls_sql = "SELECT tname " + &
			"FROM tab " + &
			"WHERE tabtype = 'TABLE' " + &
			" AND " + "tname >= '" + is_table + as_workdt_fr + "' " + &
			" AND " + "tname <= '" + is_table + as_workdt_to + "' "  + &
			" AND " + "substr(tname,1,7) = '" + LeftA(is_table,7) + "'"  + &
			" AND " + ls_length_sql + &
			" ORDER BY tname DESC"
	
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC cur_read_cdr_table;

//DW 초기화
ll_rows = dw_detail.RowCount()
If ll_rows > 0 Then dw_detail.RowsDiscard(1, ll_rows, Primary!)
ll_rows = 0

Do While(True)
	FETCH cur_read_cdr_table
	INTO :ls_tname;

	If SQLCA.SQLCode < 0 Then
		clipboard(ls_sql)
		f_msg_sql_err(title, " cur_read_cdr_table")
		CLOSE cur_read_cdr_table;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
		  
	//검색된 테이블에서 자료를 읽기
	ls_sql_1 = ls_ws_sql + " FROM " + ls_tname + " a, areamst b, zone z , svcmst s , cdrflag_info c Where " + &
				 + ls_where + &
			  " ORDER BY a.rtime DESC, a.customerid asc, a.pid asc "
	
	dw_tmp.SetSqlSelect(ls_sql_1)
	
	//조회
	ll_rows = dw_tmp.Retrieve()
	If ll_rows > 0 Then
		//복사한다.
		dw_tmp.RowsCopy(1,dw_tmp.RowCount(), &
										Primary!,dw_detail ,1, Primary!)
	End If    
Loop
CLOSE cur_read_cdr_table;

If dw_detail.rowcount() > 0 Then
	dw_detail.SetSort(" a.rtime D, a.customerid A, a.pid A, a.STIME D")
	dw_detail.Sort()
End If

return 1
end function

public function integer wf_cdr_inq_1 (string as_svctype, string as_workdt_fr, string as_customerid, string as_pid);//**   Argument : as_svctype //서비스구분(선불/후불)
//						as_workdt_fr //일자 from
//						as_workdt_to //일자 to

String ls_sql, ls_type, ls_tname, ls_nodeno, ls_sql_1, ls_pre_svctype[], ls_post_svctype[]
String ls_where, ls_validkey, ls_rtelnum, ls_seqno, ls_pid, ls_ref_desc, ls_svctype, ls_customerid
Long ll_insrow, ll_rows, ll_seqno, ll_biltime
Integer li_cnt, li_cnt_1, i
DateTime ldt_stime, ldt_etime, ldt_crtdt, ldt_rtime
Dec ldc_bilamt
String ls_originnum, ls_areacod, ls_countrycod, ls_zoncod, ls_areanm, ls_zonnm, ls_stelnum, ls_flag_group
String ls_format
String ls_table, ls_order_sql
String ls_svccode, ls_sacnum, ls_priceplan
String ls_stime_fr, ls_stime_to
String ls_pbxno, ls_inid, ls_outid

//선불 서비스 Type
ls_svctype = fs_get_control("B1", "P211", ls_ref_desc)
li_cnt= fi_cut_string(ls_svctype, ";", ls_pre_svctype[])	
//후불 서비스 Type
ls_svctype = fs_get_control("B1", "P212", ls_ref_desc)
li_cnt_1= fi_cut_string(ls_svctype, ";", ls_post_svctype[])	
ll_insrow = 0

ls_format = "##0"
For i = 1 To integer(is_format)
   If i = 1 Then ls_format += "."
   ls_format += "0"
Next
dw_detail.Modify("bilamt.Format = '" + ls_format + "'")

/*For i = 1 To li_cnt
	If as_svctype = ls_pre_svctype[i] Then
		ls_type = 'PRE_CDR'
		Exit;
   End If
Next

For i = 1 To li_cnt_1
	If as_svctype = ls_post_svctype[i] Then
		ls_type = 'POST_CDR'
		Exit;
   End If
Next */


ls_table = is_table + as_workdt_fr
ls_sql = " SELECT a.customerid, " + &
		"		a.rtime, " + &
		"		a.STIME, " + &
		"		a.ETIME, " + &
		"		a.BILTIME, " + &
		"		a.STELNUM, " + &
		"		a.RTELNUM, " + &
		"		a.BILAMT,  " + &
		"		a.VALIDKEY,  " + &
		"		to_char(a.SEQNO),  " + &
		"		a.CRTDT,  " + &
		"		a.pid, " + &
		"		a.nodeno,  " + &
		"		a.originnum,  " + &
		"		a.areacod,  " + &
		"		a.countrycod,  " + &
		"		a.zoncod,  " + &
		"		b.areanm,  " + &
		"		z.zonnm, " + &
		"     a.result," + &
		"		s.svcdesc," + &
		"		a.inid," + &
		"		a.outid," + &
		"		a.flag," + &
		"     c.flag_group," + &
		"     a.sacnum," + &
		"     a.pbxno," + &
		"     a.priceplan," + &
		"     a.itemcod," + &
		"     a.rtelnum2," + &
		"     a.stelnum2" + &
		"	FROM " + ls_table + " a, areamst b, zone z , svcmst s , cdrflag_info c" + &
		"  Where a.areacod = b.areacod(+) " + &
		"    And a.zoncod = z.zoncod(+) " + &
		"    And a.svccod = s.svccod(+) " + &
		"    And a.flag = c.flag(+) "

ls_order_sql  = " ORDER BY a.rtime desc, a.customerid asc, a.pid asc "

ls_customerid = as_customerid
ls_pid = as_pid
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_rtelnum = Trim(dw_cond.Object.rtelnum[1])
ls_stelnum = Trim(dw_cond.Object.stelnum[1])
ls_flag_group = Trim(dw_cond.Object.flag_group[1])
ls_svccode =  Trim(dw_cond.object.svccode[1])
ls_sacnum = Trim(dw_cond.object.sacnum[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_stime_fr = Trim(String(dw_cond.object.stime_fr[1],'yyyymmdd'))
ls_stime_to = Trim(String(dw_cond.object.stime_to[1],'yyyymmdd'))
ls_pbxno = Trim(dw_cond.object.pbxno[1])
ls_inid = Trim(dw_cond.object.inid[1])
ls_outid = Trim(dw_cond.object.outid[1])
If Isnull(ls_validkey) Then ls_validkey = ""
If Isnull(ls_rtelnum) Then ls_rtelnum = ""
If Isnull(ls_stelnum) Then ls_stelnum = ""
If Isnull(ls_flag_group) Then ls_flag_group = ""
If Isnull(ls_svccode) Then ls_svccode = ""
If Isnull(ls_sacnum) Then ls_sacnum = ""
If Isnull(ls_priceplan) Then ls_priceplan = ""
If Isnull(ls_stime_fr) Then ls_stime_fr = ""
If Isnull(ls_stime_to) Then ls_stime_to = ""
If Isnull(ls_pbxno) Then ls_pbxno = ""
If Isnull(ls_inid) Then ls_inid = ""
If Isnull(ls_outid) Then ls_outid = ""


//기본 Where 문
ls_where = " "
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.validkey = '" + ls_validkey + "'"
End if

If as_svctype <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svctype = '" + as_svctype+ "'"
End if

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.customerid = '" + ls_customerid + "'"

End If

If ls_svccode <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccode + "'"
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pid = '" + ls_pid + "'"
End If

If ls_rtelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.rtelnum like '" + ls_rtelnum + "%'"
End if

If ls_stelnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stelnum like '" + ls_stelnum + "%'"
End if

If ls_flag_group <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " c.flag_group = '" + ls_flag_group + "'"
End if

If ls_sacnum <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.sacnum = '" + ls_sacnum + "'"
End if

If ls_priceplan <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "'"
End if

If ls_stime_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(a.stime, 'YYYYMMDD') >= '"+ ls_stime_fr +"'"
End If

If ls_stime_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where	+= "to_char(a.stime, 'YYYYMMDD') <= '"+ ls_stime_to +"'"
End If

If ls_pbxno <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.pbxno = '" + ls_pbxno + "'"
End if

If ls_inid <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.inid like '" + ls_inid + "%'"
End if

If ls_outid <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.outid like '" + ls_outid + "%'"
End if
	
ls_sql = ls_sql + ls_where + ls_order_sql

dw_detail.SetSqlSelect(ls_sql)

//조회
dw_detail.Retrieve()

return 1
end function

on ubs_w_inq_deposit_retrieve.create
int iCurrent
call super::create
this.dw_tmp=create dw_tmp
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_tmp
this.Control[iCurrent+2]=this.p_1
end on

on ubs_w_inq_deposit_retrieve.destroy
call super::destroy
destroy(this.dw_tmp)
destroy(this.p_1)
end on

event open;call super::open;DATE		ld_start_date,		ld_current_date

p_1.TriggerEvent("ue_disable")

//손모양 없애기
dw_detail.SetRowFocusIndicator(Off!)
end event

event ue_ok;call super::ue_ok;//조회
STRING	ls_customerid,		ls_contractseq,		ls_paydt_fr,		ls_paydt_to,			ls_partner,		&
			ls_where,			ls_basecod,				ls_hash	
LONG		ll_row

dw_cond.AcceptText()

ls_customerid	= Trim(dw_cond.object.customerid[1])
ls_contractseq = String(dw_cond.object.contractseq[1])
ls_paydt_fr		= String(dw_cond.object.actdt_from[1], 'yyyymmdd')
ls_paydt_to		= String(dw_cond.object.actdt_to[1], 'yyyymmdd')
ls_partner		= Trim(dw_cond.object.partner[1])
ls_basecod		= Trim(dw_cond.object.basecod[1])

If Isnull(ls_customerid)	Then ls_customerid	= ""				
If Isnull(ls_contractseq)	Then ls_contractseq	= ""				
If Isnull(ls_paydt_fr)		Then ls_paydt_fr		= ""
If Isnull(ls_paydt_to)		Then ls_paydt_to		= ""
If Isnull(ls_partner)		Then ls_partner		= ""
If Isnull(ls_basecod)		Then ls_basecod		= ""

SetPointer(HourGlass!)

//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.CUSTOMERID = '" + ls_customerid + "'"
END IF

IF ls_contractseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
END IF

IF ls_paydt_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.PAYDT >= TO_DATE('" + ls_paydt_fr + "', 'YYYYMMDD')"
END IF

IF ls_paydt_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.PAYDT <= TO_DATE('" + ls_paydt_to + "', 'YYYYMMDD')"
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.PARTNER = '" + ls_partner + "'"
END IF

IF ls_basecod <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " B.BASECOD = '" + ls_basecod + "'"
END IF

//Retrieve
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0 THEN
	f_msg_info(1000, Title, "")	
END IF	

SetRedraw(FALSE)

p_1.TriggerEvent("ue_enable")
SetRedraw(TRUE)
SetPointer(Arrow!)

dw_detail.SetFocus()
end event

type dw_cond from w_a_inq_m`dw_cond within ubs_w_inq_deposit_retrieve
integer x = 59
integer y = 44
integer width = 3022
integer height = 284
string dataobject = "ubs_dw_inq_deposit_retrieve_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;DataWindowChild 	ldwc_contractseq
Long 					li_rc,				ll_row
String 				ls_sql,		ls_customernm

Choose Case dwo.name
	Case "customerid"		
		
		SELECT CUSTOMERNM INTO :ls_customernm
		FROM   CUSTOMERM
		WHERE  CUSTOMERID = :data;
		
		IF IsNull(ls_customernm) THEN ls_customernm = ""
		
		IF ls_customernm = "" THEN
			f_msg_usr_err(2100, Title, "CustomerID Not Found!")
			THIS.Object.customerid[1] = ""
			THIS.Object.customernm[1] = ""
	  		Return 2  		//선택 취소 focus는 그곳에
		End If

		THIS.Object.customernm[1] = ls_customernm		
		
		li_rc = THIS.GetChild("contractseq", ldwc_contractseq)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF	
		
		ls_sql = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
					" FROM   CONTRACTMST A, PRICEPLANMST B " + &
					" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
					" AND    A.CUSTOMERID = '" + data + "' " +&
					" ORDER BY A.CONTRACTSEQ ASC "
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_row = ldwc_contractseq.Retrieve()

		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "Model Retrieve()")
			RETURN -2
		END IF					

End Choose	
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If THIS.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
		End If
		
		This.Event ItemChanged(1, This.Object.customerid, iu_cust_help.is_data[1])

End Choose

Return 0 
end event

type p_ok from w_a_inq_m`p_ok within ubs_w_inq_deposit_retrieve
integer x = 3154
integer y = 68
end type

type p_close from w_a_inq_m`p_close within ubs_w_inq_deposit_retrieve
integer x = 3456
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within ubs_w_inq_deposit_retrieve
integer width = 3058
integer height = 340
end type

type dw_detail from w_a_inq_m`dw_detail within ubs_w_inq_deposit_retrieve
integer y = 364
integer width = 3991
integer height = 1544
string dataobject = "ubs_dw_inq_deposit_retrieve_mas"
boolean hsplitscroll = false
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.payseq_t
//uf_init(ldwo_SORT)
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

type dw_tmp from u_d_base within ubs_w_inq_deposit_retrieve
boolean visible = false
integer x = 41
integer y = 1776
integer width = 3456
integer height = 248
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_inq_cdryyyymmdd_2_v20"
end type

type p_1 from u_p_saveas within ubs_w_inq_deposit_retrieve
integer x = 3159
integer y = 192
boolean bringtotop = true
end type

