//
//  MessageBubbleView.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import SwiftUI

struct ChatBubbleShape: Shape {
    var isUser: Bool

    func path(in rect: CGRect) -> Path {
        isUser ? userPath(in: rect) : assistantPath(in: rect)
    }

    private func userPath(in rect: CGRect) -> Path {
        let r: CGFloat = 17
        var p = Path()

        // Top-left corner
        p.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        // Top edge
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        // Top-right corner
        p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                 tangent2End: CGPoint(x: rect.maxX, y: rect.minY + r), radius: r)
        // Right edge — stop before tail
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 8))
        // Tail: outer curve from right edge to tip
        p.addCurve(to: CGPoint(x: rect.maxX + 5, y: rect.maxY + 2),
                   control1: CGPoint(x: rect.maxX, y: rect.maxY),
                   control2: CGPoint(x: rect.maxX + 5, y: rect.maxY))
        // Tail: inner curve from tip back to bottom edge
        p.addCurve(to: CGPoint(x: rect.maxX - 12, y: rect.maxY),
                   control1: CGPoint(x: rect.maxX + 3, y: rect.maxY + 4),
                   control2: CGPoint(x: rect.maxX - 4, y: rect.maxY))
        // Bottom edge
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        // Bottom-left corner
        p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                 tangent2End: CGPoint(x: rect.minX, y: rect.maxY - r), radius: r)
        // Left edge
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        // Top-left corner
        p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                 tangent2End: CGPoint(x: rect.minX + r, y: rect.minY), radius: r)

        p.closeSubpath()
        return p
    }

    private func assistantPath(in rect: CGRect) -> Path {
        let r: CGFloat = 17
        var p = Path()

        // Top-right corner
        p.move(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        // Top edge (right to left)
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.minY))
        // Top-left corner
        p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                 tangent2End: CGPoint(x: rect.minX, y: rect.minY + r), radius: r)
        // Left edge — stop before tail
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 8))
        // Tail: outer curve from left edge to tip
        p.addCurve(to: CGPoint(x: rect.minX - 5, y: rect.maxY + 2),
                   control1: CGPoint(x: rect.minX, y: rect.maxY),
                   control2: CGPoint(x: rect.minX - 5, y: rect.maxY))
        // Tail: inner curve from tip back to bottom edge
        p.addCurve(to: CGPoint(x: rect.minX + 12, y: rect.maxY),
                   control1: CGPoint(x: rect.minX - 3, y: rect.maxY + 4),
                   control2: CGPoint(x: rect.minX + 4, y: rect.maxY))
        // Bottom edge
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
        // Bottom-right corner
        p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                 tangent2End: CGPoint(x: rect.maxX, y: rect.maxY - r), radius: r)
        // Right edge
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + r))
        // Top-right corner
        p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                 tangent2End: CGPoint(x: rect.maxX - r, y: rect.minY), radius: r)

        p.closeSubpath()
        return p
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }
    private var bubbleColor: Color {
        isUser ? .blue : Color(.systemGray5)
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        ChatBubbleShape(isUser: isUser)
                            .fill(bubbleColor)
                    }
                    .padding(isUser ? .trailing : .leading, 8)

                if message.isStreaming {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.leading, 4)
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
