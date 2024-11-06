class QuoteMailer < ApplicationMailer
  def send_quote(customer_email)
    attachments['surtibox_quote.pdf'] = File.read('quotes/Quote.pdf')
    mail(to: customer_email, subject: 'Your Surtibox Quote')
  end
end