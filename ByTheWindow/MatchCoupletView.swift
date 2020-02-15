//
//  MatchCoupletView.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/2/14.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct MatchCoupletView: View {
    @State var input = ""
    @State var output = ""
    @State var tempInput = ""
    
    // TODO: 2. 重构代码，划分子组件
    var body: some View {
        VStack(spacing: 30) {
            Text("智能对对联")
            .font(.custom("MaShanZheng-Regular", size: 50))
                .padding(.bottom, 30)
            
            HStack(spacing: 20) {
                TextField("请输入上联", text: $tempInput)
                    .padding(10) .overlay(RoundedRectangle(cornerRadius: 20).stroke( Color.gray.opacity(0.7)))
                    .frame(width: 400, height: 50)
                
                // TODO: 3. 添加点击事件
                ZStack {
                    Rectangle()
                        .frame(width: 70, height: 45)
                    .cornerRadius(20)
                        .foregroundColor(Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)).opacity(0.8))
                        .shadow(color: Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)), radius: 10, x: 0, y: 2)
                    Text("确定").font(.custom("MaShanZheng-Regular", size: 20))
                        .foregroundColor(.white)
                }
            }
            
            // TODO: 1. 将input和output绑定在CoupletTextView上
            CoupletTextView(title: "上联：", text: "万事胜意" )
            CoupletTextView(title: "下联：", text: "一生欢喜")
            
            ZStack {
                Rectangle()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)).opacity(0.8))
                    .rotationEffect(.degrees(45))
                    .shadow(color: Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)), radius: 10, x: 0, y: 2)
                    .overlay(Rectangle().stroke( Color.white).frame(width: 60, height: 60)
                        .rotationEffect(.degrees(45)))
                Text("对下联").font(.custom("MaShanZheng-Regular", size: 20))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            Spacer()
        }
        .frame(minWidth: 0,  maxWidth: .infinity)
        .padding(.top, 120)
        
    }
}

struct MatchCoupletView_Previews: PreviewProvider {
    static var previews: some View {
        MatchCoupletView()
            .previewLayout(.fixed(width: 1112, height: 834))
    }
}

struct CoupletTextView: View {
    var title = "上联："
    var text = "万事胜意"
    
    var body: some View {
        HStack(alignment: VerticalAlignment.bottom) {
            Text(title)
                .font(.custom("MaShanZheng-Regular", size: 40))
            VStack(spacing: 5) {
                Text(text)
                    .font(.custom("MaShanZheng-Regular", size: 40))
                
                Rectangle()
                    .frame(width: CGFloat(text.count * 80) , height: 1)
                    .foregroundColor(Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)))
            }
        }.padding(.top, 50)
    }
}
