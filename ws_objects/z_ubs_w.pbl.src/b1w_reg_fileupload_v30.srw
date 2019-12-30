$PBExportHeader$b1w_reg_fileupload_v30.srw
$PBExportComments$[jwlee] 청구파일 Upload
forward
global type b1w_reg_fileupload_v30 from w_a_reg_m
end type
type dw_file from datawindow within b1w_reg_fileupload_v30
end type
type st_message from statictext within b1w_reg_fileupload_v30
end type
type p_saveas from u_p_saveas within b1w_reg_fileupload_v30
end type
type gb_1 from groupbox within b1w_reg_fileupload_v30
end type
end forward

global type b1w_reg_fileupload_v30 from w_a_reg_m
integer width = 4590
integer height = 1872
dw_file dw_file
st_message st_message
p_saveas p_saveas
gb_1 gb_1
end type
global b1w_reg_fileupload_v30 b1w_reg_fileupload_v30

type variables
Long il_workno
String is_item[], is_checklist[], is_rank[], is_error[], is_fileread = 'N'
String is_customerid, is_customernm, is_trdt


boolean ib_saveas = False
datawindow idw_saveas
end variables

on b1w_reg_fileupload_v30.create
int iCurrent
call super::create
this.dw_file=create dw_file
this.st_message=create st_message
this.p_saveas=create p_saveas
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
this.Control[iCurrent+2]=this.st_message
this.Control[iCurrent+3]=this.p_saveas
this.Control[iCurrent+4]=this.gb_1
end on

on b1w_reg_fileupload_v30.destroy
call super::destroy
destroy(this.dw_file)
destroy(this.st_message)
destroy(this.p_saveas)
destroy(this.gb_1)
end on

event open;call super::open;String	ls_ref_desc, ls_temp
//dw_file.Enabled = False

//청구파일 Upload 항목정의(고객맵핑키(고객통합코드);인증키;매출일자;요금항목;일반정보;고객매핑키(고객명))
//                           A001;A002;B001;C001;C002;A003
//ls_temp = fs_get_control("B7", "C760", ls_ref_desc)

//청구파일 Upload 항목정의(맵핑키-인증키;매핑키-가격정책;매출일자;요금항목;일반정보;)
//A001;A002;B001;C001;C002;A003
ls_temp = fs_get_control("ZM", "C760", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_item[])

If is_item[1] = "" Then
   F_GET_MSG(259, TITLE, 'ZM:C760')
	Close(This)
End If

//청구파일 data검증코드(인증키 존재여부;고객과 인증키의 일치체크;유일인증키체크)
//                          A1;A2;A3
//ls_temp = fs_get_control("B7", "C770", ls_ref_desc)

//청구파일 data검증코드(인증키 존재여부;고객과 인증키의 일치체크;유일인증키체크)
//A1;A2;A3
ls_temp = fs_get_control("ZM", "C770", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_checklist[])

If is_checklist[1] = "" Then
   F_GET_MSG(259, TITLE, 'ZM:C770')
	Close(This)
End If


end event

event resize;call super::resize;//p_saveas 추가
//2008-02-13 by JH
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_saveas.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	p_saveas.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event ue_extra_save;
String ls_errmsg, ls_fileformcd, ls_trdt
Long   ll_rc, LI_ERROR
double lb_count, ll_return

ll_return 		= -1
ls_errmsg 		= space(800)
ls_fileformcd = dw_cond.Object.fileformcd[1]

//처리부분...
SQLCA.B1W_INV_FILEUPLOAD(il_workno, is_trdt, ls_fileformcd, is_customerid, is_customernm, gs_user_id, ll_return, ls_errmsg, lb_count)

ll_rc = ll_return

If ll_rc < 0 Then
	messagebox("INFO", ls_errmsg )
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Return ll_rc
End If

Return 0

end event

event type integer ue_insert();call super::ue_insert;Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)


dw_detail.Object.num[ll_row]	= ll_row								//인증키
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

dw_cond.Object.iqty[1] = ll_row

Return 0

end event

event ue_ok();call super::ue_ok;Long ll_row
Int li_return
String ls_file_code, ls_workno, ls_status
String ls_where, ls_temp, ls_ref_desc, ls_result[]

dw_cond.Accepttext()


//데이터 윈도우 바꾸기 
dw_detail.DataObject = "b1dw_reg_fileupload_log_v30"
dw_detail.SetTransObject(SQLCA)

ls_file_code = fs_snvl(Trim(dw_cond.object.fileformcd[1]),"")

If is_fileread = 'N' Then
	ls_workno = fs_snvl(Trim(String(dw_cond.object.workno[1])),"")
Else
	ls_workno = String(il_workno)
End If

If ls_file_code = "" Then
//	f_msg_info(200, Title, "파일유형")
	F_GET_MSG(259, THIS.TITLE, '')
	dw_cond.SetFocus()
	dw_cond.setColumn("fileformcd")
	Return 
End If

ls_where = ""
If ls_file_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "fileformcd='" + ls_file_code + "' "
End If

If ls_workno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "To_char(workno)='" + ls_workno + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

is_fileread = 'N'

dw_file.Enabled = True
dw_detail.Enabled = True

If ll_row = 0 Then
		F_GET_MSG(268, THIS.TITLE, '')
ElseIf ll_row < 0 Then
		F_GET_MSG(295, THIS.TITLE, '')
End If

Return
end event

event ue_reset;call super::ue_reset;p_ok.TriggerEvent("ue_enable")

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

//dw_detail.Enabled = False
dw_detail.reset()

dw_cond.Enabled = True
dw_cond.reset()
dw_cond.insertRow(1)

//매출일자 set
dw_cond.Object.trdt[1] = Date(String(fdt_get_dbserver_now(), 'yyyy-mm-dd'))
dw_cond.Setfocus()

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False
RETURN 0

end event

event ue_save;Constant Int LI_ERROR = -1

Long result, ll_return


If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

ll_return = This.Trigger Event ue_extra_save()

If ll_return = -1 Then
	dw_detail.SetFocus()
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	F_GET_MSG(215, Title, '')
	Return LI_ERROR

Else
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -2 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	If iu_cust_db_app.ii_rc = -1 Then //비정상적인 데이타로 인해 에러는 났지만 저장한 한다 대신 메세지는 에러라고 함
		F_GET_MSG(215, Title, '')
		Return iu_cust_db_app.ii_rc
	Else
		If ll_return = -2 Then
			F_GET_MSG(439, Title, '')
			TriggerEvent("ue_ok")
			Return ll_return
		Else
			F_GET_MSG(214, Title, '')
		End If
	End If
End if

//저장완료
//TriggerEvent("ue_reset")
//p_ok.TriggerEvent("ue_disable")

p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = True
dw_detail.reset()

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = True

TriggerEvent("ue_ok")

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_fileupload_v30
integer x = 46
integer y = 60
integer width = 1792
integer height = 172
string dataobject = "b1dw_cnd_fileupload_v30"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::destructor;//
end event

event dw_cond::doubleclicked;//
end event

event dw_cond::itemchanged;call super::itemchanged;Decimal ll_exchange_rate, ll_margin_rate

If dwo.name= "fileformcd" Then
	
	If fs_snvl(data,' ')  <> ' ' Then
		
		dw_file.Enabled = True
	Else
		dw_file.Enabled = False
		dw_cond.reset()
		dw_cond.insertrow(0)
		dw_cond.setfocus()
		dw_cond.setcolumn('filefromcd')
		f_msg_usr_err(1100, title, "File Type")	
	End If
	
ElseIf dwo.name= "trdt" Then
	
	If fs_snvl(data,' ')  <> ' ' Then	
		//환율정보 조회
		SELECT RATE INTO :ll_exchange_rate		
		  FROM EXCHANGERATE_CDR
		 WHERE 1=1
			AND FROMDT = (SELECT MAX(FROMDT) 
			                FROM EXCHANGERATE_CDR
                        WHERE FROMDT <= TO_DATE(:data)
							 )
							 ;
		
		If SQLCA.SQLCode <> 0 Then
			F_GET_MSG(295, title, '환율을 등록하여 주십시오.')	
			Return -1
		End If
		
		//마진정보 조회
		SELECT RATE INTO :ll_margin_rate		
		  FROM MARGIN_CDR
		 WHERE 1=1
			AND FROMDT = (SELECT MAX(FROMDT) 
			                FROM MARGIN_CDR
                        WHERE FROMDT <= TO_DATE(:data)
							 )
							 ;
		
		If SQLCA.SQLCode <> 0 Then
			F_GET_MSG(295, title, '마진율을 등록하여 주십시오.')	
			Return -1
		End If
		
		//환율, 마진 정보 설정
		this.Object.exchange_rate[1] = ll_exchange_rate;
		this.Object.margin_rate[1]   = ll_margin_rate;
	Else
		//환율, 마진 정보 초기화
		this.Object.exchange_rate[1] = "";
		this.Object.margin_rate[1]   = "";		
	End If
End If
end event

event dw_cond::sqlpreview;//
end event

event dw_cond::ue_key;//
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_fileupload_v30
integer x = 3863
integer y = 72
end type

type p_close from w_a_reg_m`p_close within b1w_reg_fileupload_v30
integer x = 4169
integer y = 72
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_fileupload_v30
integer width = 1838
integer height = 244
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_fileupload_v30
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_fileupload_v30
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_fileupload_v30
integer x = 334
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_fileupload_v30
integer width = 3639
string dataobject = "b1dw_reg_fileupload_log_v30"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(Off!)
end event

event dw_detail::doubleclicked;call super::doubleclicked;//Long ll_detail_row
//
//this.accepttext()
//
//ll_detail_row = dw_detail.GetSelectedRow(0)
//
//If dw_detail.DataObject = "b1dw_reg_fileupload_log_v30" Then
//	
//	If ll_detail_row < 0 Then Return 0
//	
//	iu_cust_msg = Create u_cust_a_msg
//	iu_cust_msg.is_pgm_name = f_get_msginfo(394) //인증정보수정
//	iu_cust_msg.is_grp_name = "청구파일 업로드"
//	iu_cust_msg.is_data[1] = Trim(String(dw_detail.object.fileformcd[row]))  //파일 유형
//	iu_cust_msg.is_data[2] = Trim(String(dw_detail.object.workno[row]))      //작업번호
//	iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no]							    //프로그램 ID
//	
//	OpenWithParm(b1w_reg_fileupload_result_pop_v30, iu_cust_msg)
//	
//Else
//	Return
//	
//End If
end event

event dw_detail::clicked;
if row <= 0 then return

il_workno 	= this.object.workno[row]
is_trdt		= string(this.object.sale_month[row])
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_fileupload_v30
integer x = 32
end type

type dw_file from datawindow within b1w_reg_fileupload_v30
integer x = 1902
integer y = 80
integer width = 1833
integer height = 132
integer taborder = 12
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_file_reg_adin_v31"
boolean border = false
boolean livescroll = true
end type

event buttonclicked;String 		ls_fileformcd, 	ls_rank, 		ls_headcheck = 'Y', 	ls_check_cd, &
			ls_cust_mapping, ls_fromdt
Long 		ll_return, 		ll_check_cnt
string 		pathName, 		fileName, 		ls_fileName
Int 		value,			li_fileId

String		ls_fileRow			//파일내용이 한줄 저장되는 변수
Long		ll_fileRows = 0	    //파일의 row수가 저장되는 변수
Long		ll_iqty				//현재 입고예정인 row수
String		ls_filedata[], ls_customernm         //파일내용
String		ls_validkey, ls_priceplan, ls_customerid, ls_fileitem
Long		ll_row	,ll_filedata[]			//새로 입력된 row
Long		ll_cnt, i, ll_count, ll_file_row, ll_workno
Int			li_location, j, k, l, p, t		//Text가공시 필요한 위치정보
Long     	ll_customer, ll_validkey, ll_trdt

String		ls_cur_dir
u_api		lu_api

dw_cond.Accepttext()

CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
		lu_api = Create u_api
		
		//ls_cur_dir = GetCurrentDirectory() <-- 파워빌더 8.0부터 사용가능한 함수.
		ls_cur_dir = lu_api.uf_GetCurrentDirectoryA()
		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")
		
		lu_api.uf_SetCurrentDirectoryA(ls_cur_dir)
		
		Destroy lu_api
		IF value = 1 THEN	This.Object.filename[1] = pathName
		
	CASE "load"		//파일처리
		
     	SetPointer(HourGlass!)
		ls_fileformcd = fs_snvl(dw_cond.Object.fileformcd[1],' ')
		is_trdt       = fs_snvl(String(dw_cond.Object.trdt[1]),' ')

		IF F_CHECK_ITEM(ls_fileformcd, 	dw_cond, 1, "fileformcd", 	259, parent.Title, '1') = -1 THEN RETURN -1
		IF F_CHECK_ITEM(is_trdt, 		dw_cond, 1, "trdt", 		259, parent.Title, '2') = -1 THEN RETURN -1
		
		dw_detail.DataObject = "b1dw_inq_item_check_v30"
		dw_detail.SetTransObject(SQLCA)
		
		//삭제처리가 안된것 중 이미 등록된 데이타인지 확인
		Select Count(*)	INTO :ll_check_cnt	FROM REQUPLOAD_WORKLOG
		 Where fileformcd 	= :ls_fileformcd
		   And sale_month 	= To_date(:is_trdt,'yyyy-mm-dd')
		   And status 		<> 'C';
		
		If ll_check_cnt > 0 Then
			F_GET_MSG(202, parent.title, 'REQUPLOAD_WORKLOG ')	
			FileClose(li_fileId)
			Return
		End If
					
		ls_fileName = Trim(This.Object.filename[1])
		IF isNull(ls_fileName) THEN ls_fileName = ""
		
		IF F_CHECK_ITEM(ls_fileName, 		dw_cond, 1, "filename", 		259, parent.Title, 'File name') = -1 THEN RETURN 0

		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		
		If(IsNull(li_fileId) or li_fileId < 0) THEN
	   		F_GET_MSG(445, parent.TITLE, 'File Open Fail')
			this.setFocus()
			RETURN 0
		End If
		
		
		ll_iqty = dw_detail.rowCount()
		
		//is_checklist[2] : 고객과 인증키의 일치체크 (A2)
		SELECT Count(*)		INTO :ll_check_cnt	FROM FILEDATACHECK
		 WHERE fileformcd 	= :ls_fileformcd
		   AND CHECK_CD   	= :is_checklist[2]
		ORDER BY CHECK_CD;
		
		//End of File(return -100)을 만날때까지 파일을 한줄씩 읽는다.
		DO UNTIL( FileRead(li_fileId,ls_fileRow) = -100 )
			ll_file_row  ++
			
			for i = 1 To 150
				SetNull(ls_filedata[i])
			Next 
			
			ll_cnt = fi_cut_string(ls_fileRow,"~t", ls_filedata[])
			//ll_cnt = UpperBound(ls_filedata[])
			
			//상세정보의 head면과 청구파일의 head명을 체크
			IF ll_file_row = 1 THEN
						
				For  i = 1 To ll_cnt
				
					 Select count(*)	INTO :ll_count	FROM REQFILEFORMDET
					  WHERE fileformcd 	= :ls_fileformcd
						AND fileitem   	= :ls_filedata[i];
					 
					 If ll_count = 0 Then
						ll_row 								= dw_detail.InsertRow(0)
						dw_detail.Object.fileitem[ll_row] 	= ls_filedata[i]
//						
						dw_detail.Object.remark2[ll_row] = ls_filedata[i]
						ls_headcheck = 'N'
					 End If
					 
				Next
				
				If ls_headcheck = 'N' Then
					F_GET_MSG(441, parent.Title, '')
					FileClose(li_fileId)
					Return
				End If		
						
				If ll_check_cnt <> 0 Then 
				
					// 고객키(고객통합코드) 멥핑항목을 찾는다
					// 고객키(고객명) 멥핑항목을 찾는다
					// 고객번호가 몇번째 컬럼인지 찾는다			- UBS는 없다. - 2015-02-15. lys
					is_customerid   = 'N'
					is_customernm   = 'N'
					ls_cust_mapping = ""
				End If
				
				// 인증키 멥핑항목을 찾는다 (맵핑키-인증키 : A001)
				SELECT FILEITEM		INTO :ls_validkey		FROM REQFILEFORMDET
				 WHERE GROUPNO 		= :is_item[1]
				   AND fileformcd 	= :ls_fileformcd;
				
				If SQLCA.SQLCode < 0 Then
					F_GET_MSG(201, parent.title, 'REQFILEFORMDET(validkey) :'+SQLCA.SQLErrText)	
					Rollback;
					FileClose(li_fileId)
					Return
				End If	
				
				//인증키가 몇번째 컬럼인지 찾는다
				FOR k = 1 TO ll_cnt		
					IF ls_filedata[k] = ls_validkey THEN 	EXIT;
				NEXT
				
				
				// 가격정책 멥핑항목을 찾는다 (맵핑키-가격정책 : A002)
				SELECT FILEITEM		INTO :ls_priceplan		FROM REQFILEFORMDET
				 WHERE GROUPNO 		= :is_item[2]
				   AND fileformcd 	= :ls_fileformcd;
				
				If SQLCA.SQLCode < 0 Then
					F_GET_MSG(201, parent.title, 'REQFILEFORMDET(priceplan) :'+SQLCA.SQLErrText)	
					Rollback;
					FileClose(li_fileId)
					Return
				End If	
				
				//가격정책이 몇번째 컬럼인지 찾는다
				FOR p = 1 TO ll_cnt		
					IF ls_filedata[p] = ls_priceplan THEN 	EXIT;
				NEXT	
				
				
				
				// 개통일자 멥핑항목을 찾는다 (맵핑키-개통일자 : B001)
				SELECT FILEITEM		INTO :ls_fromdt		FROM REQFILEFORMDET
				 WHERE GROUPNO 		= :is_item[3]
				   AND fileformcd 	= :ls_fileformcd;
				
				If SQLCA.SQLCode < 0 Then
					F_GET_MSG(201, parent.title, 'REQFILEFORMDET(FROMDT) :'+SQLCA.SQLErrText)	
					Rollback;
					FileClose(li_fileId)
					Return
				End If	
				
				//가격정책이 몇번째 컬럼인지 찾는다
				FOR t = 1 TO ll_cnt		
					IF ls_filedata[t] = ls_fromdt THEN 	EXIT;
				NEXT				
				
				
				//원본데이타 입력
				Select SEQ_REQUPLOAD_NO.NEXTVAL		INTO :il_workno	FROM dual;
					  
				Insert Into REQUPLOAD_ORG_M
				values (:il_workno, :ls_fileformcd,
				        :ls_filedata[1] , :ls_filedata[2] , :ls_filedata[3] , :ls_filedata[4] , :ls_filedata[5] , :ls_filedata[6] , :ls_filedata[7] , :ls_filedata[8] , :ls_filedata[9] , :ls_filedata[10],
						:ls_filedata[11], :ls_filedata[12], :ls_filedata[13], :ls_filedata[14], :ls_filedata[15], :ls_filedata[16], :ls_filedata[17], :ls_filedata[18], :ls_filedata[19], :ls_filedata[20],
						:ls_filedata[21], :ls_filedata[22], :ls_filedata[23], :ls_filedata[24], :ls_filedata[25], :ls_filedata[26], :ls_filedata[27], :ls_filedata[28], :ls_filedata[29], :ls_filedata[30],
						:ls_filedata[31], :ls_filedata[32], :ls_filedata[33], :ls_filedata[34], :ls_filedata[35], :ls_filedata[36], :ls_filedata[37], :ls_filedata[38], :ls_filedata[39], :ls_filedata[40],
						:ls_filedata[41], :ls_filedata[42], :ls_filedata[43], :ls_filedata[44], :ls_filedata[45], :ls_filedata[46], :ls_filedata[47], :ls_filedata[48], :ls_filedata[49], :ls_filedata[50],
						:ls_filedata[51], :ls_filedata[52], :ls_filedata[53], :ls_filedata[54], :ls_filedata[55], :ls_filedata[56], :ls_filedata[57], :ls_filedata[58], :ls_filedata[59], :ls_filedata[60],
						:ls_filedata[61], :ls_filedata[62], :ls_filedata[63], :ls_filedata[64], :ls_filedata[65], :ls_filedata[66], :ls_filedata[67], :ls_filedata[68], :ls_filedata[69], :ls_filedata[70],
						:ls_filedata[71], :ls_filedata[72], :ls_filedata[73], :ls_filedata[74], :ls_filedata[75], :ls_filedata[76], :ls_filedata[77], :ls_filedata[78], :ls_filedata[79], :ls_filedata[80],
						:ls_filedata[81], :ls_filedata[82], :ls_filedata[83], :ls_filedata[84], :ls_filedata[85], :ls_filedata[86], :ls_filedata[87], :ls_filedata[88], :ls_filedata[89], :ls_filedata[90],
						:ls_filedata[91], :ls_filedata[92], :ls_filedata[93], :ls_filedata[94], :ls_filedata[95], :ls_filedata[96], :ls_filedata[97], :ls_filedata[98], :ls_filedata[99], :ls_filedata[100],
						:ls_filedata[101],:ls_filedata[102],:ls_filedata[103],:ls_filedata[104],:ls_filedata[105],:ls_filedata[106],:ls_filedata[107],:ls_filedata[108],:ls_filedata[109],:ls_filedata[110],
						:ls_filedata[111],:ls_filedata[112],:ls_filedata[113],:ls_filedata[114],:ls_filedata[115],:ls_filedata[116],:ls_filedata[117],:ls_filedata[118],:ls_filedata[119],:ls_filedata[120],
						:ls_filedata[121],:ls_filedata[122],:ls_filedata[123],:ls_filedata[124],:ls_filedata[125],:ls_filedata[126],:ls_filedata[127],:ls_filedata[128],:ls_filedata[129],:ls_filedata[130],
						:ls_filedata[131],:ls_filedata[132],:ls_filedata[133],:ls_filedata[134],:ls_filedata[135],:ls_filedata[136],:ls_filedata[137],:ls_filedata[138],:ls_filedata[139],:ls_filedata[140],
						:ls_filedata[141],:ls_filedata[142],:ls_filedata[143],:ls_filedata[144],:ls_filedata[145],:ls_filedata[146],:ls_filedata[147],:ls_filedata[148],:ls_filedata[149],:ls_filedata[150],
						:gs_user_id,sysdate);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert REQUPLOAD_ORG_M Table")
					Rollback;
			         FileClose(li_fileId)
					Return
				End If
							
			END IF	
			
			IF ll_file_row > 1 THEN
				If LenA(trim(ls_filedata[1])) = 0 Then	Continue;
				
//				If ll_check_cnt = 0 Then 
//					ls_cust_mapping = ''
//					F_GET_MSG(443, TITLE, 'Mapping Key')
//					Rollback;
//					FileClose(li_fileId)
//					Return
//				Else
//					ls_cust_mapping = ls_filedata[j]
//				End If

//				UBS는 고객번호가 없기 때문에 Pass~ - 2015.03.22. lys
//				If ll_check_cnt = 0 Then 
//			      ls_cust_mapping = ''
//			   Else
//			      ls_cust_mapping = ls_filedata[j]
//			   End If

				// 인증키 멥핑항목을 찾는다 (맵핑키-인증키 : A001)
				If IsNull(ls_filedata[k]) or ls_filedata[k] = "" Then
					F_GET_MSG(453, parent.TITLE, String(ll_file_row - 1, '###,0') + ' Line')
					Rollback;
					FileClose(li_fileId)
					Return
				End If				
				
				// 가격정책 멥핑항목을 찾는다 (맵핑키-가격정책 : A002)
				If IsNull(ls_filedata[p]) or ls_filedata[p] = "" Then
					F_GET_MSG(454, parent.TITLE, String(ll_file_row - 1, '###,0') + ' Line')
					Rollback;
					FileClose(li_fileId)
					Return
				End If		
				
				// 개통일자 멥핑항목을 찾는다 (맵핑키-개통일자 : B001)
				If IsNull(ls_filedata[t]) or ls_filedata[t] = "" Then
					F_GET_MSG(454, parent.TITLE, String(ll_file_row - 1, '###,0') + ' Line')
					Rollback;
					FileClose(li_fileId)
					Return
				End If		
				
				//인증키보정
				if LenA(trim(ls_filedata[k])) = 10 and MidA(trim(ls_filedata[k]),1,1) <> '0' then
					ls_filedata[k] = '0' +ls_filedata[k]
				end if
				
				//개통일자보정
				ls_filedata[t] = MidA(trim(ls_filedata[t]),1,10)
				
				
				Insert Into REQUPLOAD_ORG_D 
					values ( :il_workno, :ll_file_row - 1, :ls_filedata[k] , :ls_filedata[p],  :ls_filedata[t],
						:ls_filedata[1] , :ls_filedata[2] , :ls_filedata[3] , :ls_filedata[4] , :ls_filedata[5] , :ls_filedata[6] , :ls_filedata[7] , :ls_filedata[8] , :ls_filedata[9] , :ls_filedata[10],
						:ls_filedata[11], :ls_filedata[12], :ls_filedata[13], :ls_filedata[14], :ls_filedata[15], :ls_filedata[16], :ls_filedata[17], :ls_filedata[18], :ls_filedata[19], :ls_filedata[20],
						:ls_filedata[21], :ls_filedata[22], :ls_filedata[23], :ls_filedata[24], :ls_filedata[25], :ls_filedata[26], :ls_filedata[27], :ls_filedata[28], :ls_filedata[29], :ls_filedata[30],
						:ls_filedata[31], :ls_filedata[32], :ls_filedata[33], :ls_filedata[34], :ls_filedata[35], :ls_filedata[36], :ls_filedata[37], :ls_filedata[38], :ls_filedata[39], :ls_filedata[40],
						:ls_filedata[41], :ls_filedata[42], :ls_filedata[43], :ls_filedata[44], :ls_filedata[45], :ls_filedata[46], :ls_filedata[47], :ls_filedata[48], :ls_filedata[49], :ls_filedata[50],
						:ls_filedata[51], :ls_filedata[52], :ls_filedata[53], :ls_filedata[54], :ls_filedata[55], :ls_filedata[56], :ls_filedata[57], :ls_filedata[58], :ls_filedata[59], :ls_filedata[60],
						:ls_filedata[61], :ls_filedata[62], :ls_filedata[63], :ls_filedata[64], :ls_filedata[65], :ls_filedata[66], :ls_filedata[67], :ls_filedata[68], :ls_filedata[69], :ls_filedata[70],
						:ls_filedata[71], :ls_filedata[72], :ls_filedata[73], :ls_filedata[74], :ls_filedata[75], :ls_filedata[76], :ls_filedata[77], :ls_filedata[78], :ls_filedata[79], :ls_filedata[80],
						:ls_filedata[81], :ls_filedata[82], :ls_filedata[83], :ls_filedata[84], :ls_filedata[85], :ls_filedata[86], :ls_filedata[87], :ls_filedata[88], :ls_filedata[89], :ls_filedata[90],
						:ls_filedata[91], :ls_filedata[92], :ls_filedata[93], :ls_filedata[94], :ls_filedata[95], :ls_filedata[96], :ls_filedata[97], :ls_filedata[98], :ls_filedata[99], :ls_filedata[100],
						:ls_filedata[101],:ls_filedata[102],:ls_filedata[103],:ls_filedata[104],:ls_filedata[105],:ls_filedata[106],:ls_filedata[107],:ls_filedata[108],:ls_filedata[109],:ls_filedata[110],
						:ls_filedata[111],:ls_filedata[112],:ls_filedata[113],:ls_filedata[114],:ls_filedata[115],:ls_filedata[116],:ls_filedata[117],:ls_filedata[118],:ls_filedata[119],:ls_filedata[120],
						:ls_filedata[121],:ls_filedata[122],:ls_filedata[123],:ls_filedata[124],:ls_filedata[125],:ls_filedata[126],:ls_filedata[127],:ls_filedata[128],:ls_filedata[129],:ls_filedata[130],
						:ls_filedata[131],:ls_filedata[132],:ls_filedata[133],:ls_filedata[134],:ls_filedata[135],:ls_filedata[136],:ls_filedata[137],:ls_filedata[138],:ls_filedata[139],:ls_filedata[140],
						:ls_filedata[141],:ls_filedata[142],:ls_filedata[143],:ls_filedata[144],:ls_filedata[145],:ls_filedata[146],:ls_filedata[147],:ls_filedata[148],:ls_filedata[149],:ls_filedata[150],
						:gs_user_id,:gs_user_id,sysdate,sysdate);
								
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert REQUPLOAD_ORG_D Table")
				   	Rollback;
					FileClose(li_fileId)
					Return
				End If
			END IF
		LOOP
		FileClose(li_fileId) //파일닫기
		
		
		
		//작업로그 저장
		INSERT INTO REQUPLOAD_WORKLOG (
                    WORKNO,         FILEFORMCD,   LOADFILENM,    REQCNT,     ERRCNT
                  , STARTDT,        ENDDT,        STATUS
                  , CRT_USER,       UPDT_USER,    CRTDT,         UPDT
                  , SALE_MONTH )
             VALUES (
                    :il_workno,       :ls_fileformcd, :ls_fileformcd,  0, 0
                  , SYSDATE,   SYSDATE,      'S'
                  , :gs_user_id,         :gs_user_id,       SYSDATE,       SYSDATE
                  , TO_DATE(:is_trdt,'YYYY-MM-DD')
                    );
						  
		If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert REQUPLOAD_WORKLOG Table")
				   	Rollback;
					FileClose(li_fileId)
					Return
		End If
					
		//File DW 활성화
		dw_file.Enabled 	= True
		dw_detail.Enabled 	= True
		
		COMMIT;
		
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
		ll_return 		= Parent.TriggerEvent("ue_save")		
		
		
		SetPointer(Arrow!)
		is_fileread 	= 'Y'
		
		Parent.TriggerEvent("ue_ok")	
		
END CHOOSE


end event

event constructor;
InsertRow(0)
end event

type st_message from statictext within b1w_reg_fileupload_v30
boolean visible = false
integer x = 1833
integer y = 200
integer width = 1179
integer height = 96
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 82899184
string text = "none"
boolean border = true
boolean focusrectangle = false
end type

type p_saveas from u_p_saveas within b1w_reg_fileupload_v30
event ue_saveas_init ( )
integer x = 713
integer y = 1596
boolean bringtotop = true
boolean originalsize = false
end type

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_detail
end event

event clicked;f_excel_ascii1(dw_detail,'파일명을 입력하세요')

//Boolean lb_return
//Integer li_return
//String ls_curdir
//u_api lu_api
//
//If dw_detail.RowCount() <= 0 Then
//	f_msg_info(1000, parent.Title, "Data exporting")
//	Return
//End If
//
//lu_api = Create u_api
//ls_curdir = lu_api.uf_getcurrentdirectorya()
//If IsNull(ls_curdir) Or ls_curdir = "" Then
//	f_msg_info(9000, parent.Title, "Can't get the Information of current directory.")
//	Destroy lu_api
//	Return
//End If
//
//li_return = dw_detail.SaveAs("", Excel!, True)
//
//lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
//If li_return <> 1 Then
//	f_msg_info(9000, parent.Title, "User cancel current job.")
//Else
//	f_msg_info(9000, parent.Title, "Data export finished.")
//End If
//
//Destroy lu_api
//
end event

type gb_1 from groupbox within b1w_reg_fileupload_v30
integer x = 1879
integer width = 1874
integer height = 244
integer taborder = 11
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

