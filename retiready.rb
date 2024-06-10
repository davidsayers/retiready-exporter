#!/usr/bin/env ruby

# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'api_2captcha'
require 'erb'

class Retiready
  def initialize(username, password, plan_numbers, two_capatch_key)
    @username = username
    @password = password
    @plan_numbers = plan_numbers
    @two_capatch_key = two_capatch_key
    @site_key = '6LencYoUAAAAAO1hG4kJoH3P62xnUxqgLiqvBkwB'
  end

  def metrics
    captcha_response = solve_capatch
    cookies = retiready_login_cookies(captcha_response)
    plan_infos = []
    @plan_numbers.split(',').each do |plan_number|
      plan_infos << retiready_plan_info(plan_number, cookies)
    end
    plan_infos
  end

  private

  def cookies_hash(cookies)
    cook = {}
    cookies.each do |cookie|
      k, v = cookie.split('=')
      cook[k] = v
    end
    cook
  end

  def encode_url(string)
    ERB::Util.url_encode(string)
  end

  def solve_capatch
    client = Api2Captcha.new(@two_capatch_key)
    resp = client.recaptcha_v2(
      {
        googlekey: @site_key,
        pageurl: 'https://retiready.co.uk/public/sign-in.html',
        invisible: 1
      }
    )
    resp['request']
  end

  def retiready_login_cookies(captcha_response)
    payload = "username=#{encode_url(@username)}&password=#{encode_url(@password)}&g-recaptcha-response=#{captcha_response}&automation=true&sitekey=#{@site_key}&captchaResponse=#{captcha_response}"

    begin
      RestClient::Request.execute(
        method: :post,
        url: 'https://retiready.co.uk/api/customer/login',
        payload: payload
      )
    rescue RestClient::ExceptionWithResponse => e
    end

    cookies_hash(e.http_headers[:set_cookie])
  end

  def retiready_plan_info(plan_number, cookies)
    cookies = {
      'rr-application-session' => cookies['rr-application-session'].gsub('; Domain', ''),
      'PD-S-SESSION-ID' => cookies['PD-S-SESSION-ID'].gsub('; Path', ''),
      'rr-application-session-data' => cookies['rr-application-session-data']
    }

    headers = {
      'x-requested-with' => 'XMLHttpRequest'
    }

    resp = RestClient::Request.execute(
      method: :get,
      url: "https://retiready.co.uk/api/product/#{plan_number}",
      headers: headers,
      cookies: cookies
    )

    { name: JSON.parse(resp.body)['name'], value: JSON.parse(resp.body)['value'] }
  end
end
