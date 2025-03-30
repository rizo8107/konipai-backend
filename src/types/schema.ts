/**
 * Schema types for the Konipai CRM
 */

export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  avatar?: string;
  role: 'admin' | 'user' | 'manager';
  created: string;
  updated: string;
}

export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  sku?: string;
  image?: string;
  category?: string;
  stock?: number;
  created: string;
  updated: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  product?: Product;
  quantity: number;
  price: number;
  created: string;
  updated: string;
}

export interface Order {
  id: string;
  user_id: string;
  user?: User;
  customer_name: string;
  items?: OrderItem[];
  status: 'pending' | 'processing' | 'shipping' | 'delivered' | 'cancelled';
  total: number;
  payment_method?: string;
  payment_status?: 'pending' | 'paid' | 'failed';
  shipping_address?: string;
  shipping_method?: string;
  shipping_cost?: number;
  tracking_number?: string;
  notes?: string;
  created: string;
  updated: string;
} 