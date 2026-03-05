export const CART_KEY = "zapfe_cart_v1"

export const getCart = () => {
  try {
    return JSON.parse(window.localStorage.getItem(CART_KEY) || "[]")
  } catch (_error) {
    return []
  }
}

export const saveCart = (cart) => {
  window.localStorage.setItem(CART_KEY, JSON.stringify(cart))
}

export const upsertCartItem = (item) => {
  const cart = getCart()
  const existing = cart.find((entry) => entry.variantId === item.variantId)

  if (existing) {
    existing.qty += item.qty || 1
  } else {
    cart.push({ ...item, qty: item.qty || 1 })
  }

  saveCart(cart)
  return cart
}
