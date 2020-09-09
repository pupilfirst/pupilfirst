module Types
  class QrCorner < Types::BaseEnum
    value 'Hidden', 'QR Code not shown'
    value 'TopLeft', 'QR Code shown at the top-left'
    value 'TopRight', 'QR Code shown at the top-right'
    value 'BottomLeft', 'QR Code shown at the bottom-left'
    value 'BottomRight', 'QR Code shown at the bottom-right'
  end
end
