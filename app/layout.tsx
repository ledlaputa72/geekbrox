import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'v0 API Interface Preview',
  description: 'Dream Theme - v0 API Usage Documentation',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="bg-background">{children}</body>
    </html>
  )
}
