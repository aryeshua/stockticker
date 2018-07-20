require 'spec_helper'
require 'rails_helper'


feature 'Visitor registers, logs out, and signs in' do

 	scenario 'with valid email and password' do

    # Register, sign in, log out

    sign_up_with 'valid@example.com', 'password'
    expect(page).to have_content("Logout")
    click_link('Logout')
    sign_in_with 'valid@example.com', 'password'
    expect(page).to have_content("Logout")

  end

  scenario 'adds valid stocks and confirm they were added' do

    # Register, sign in, and log out

    sign_up_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')
    click_link('Logout')
    sign_in_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')

    # Add a few stocks and check that they are visible under Watch List

    find(:css, "input[id$='stock_ticker']").set("amzn")
    click_button 'Add'
    expect(page).to have_link('AMZN')

    find(:css, "input[id$='stock_ticker']").set("aapl")
    click_button 'Add'
    expect(page).to have_link('AAPL')

    find(:css, "input[id$='stock_ticker']").set("goog")
    click_button 'Add'
    expect(page).to have_link('GOOG')

  end

  scenario 'adds valid stocks, confirm they were added, and then delete them' do

    # Register, log out, and sign in again

    sign_up_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')
    click_link('Logout')
    sign_in_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')

    # Add a few stocks and check that they are visible under Watch List

    find(:css, "input[id$='stock_ticker']").set("amzn")
    click_button 'Add'
    expect(page).to have_link('AMZN')

    find(:css, "input[id$='stock_ticker']").set("aapl")
    click_button 'Add'
    expect(page).to have_link('AAPL')

    find(:css, "input[id$='stock_ticker']").set("goog")
    click_button 'Add'
    expect(page).to have_link('GOOG')

    # Delete the stocks and confirm that they are no longer visible under Watch List

    page.find(:xpath, "//a[@id='AMZN_destroy'][text()='Delete']").click
    expect(page).to have_no_content('AMZN')


    page.find(:xpath, "//a[@id='AAPL_destroy'][text()='Delete']").click
    expect(page).to have_no_content('AAPL')


    page.find(:xpath, "//a[@id='GOOG_destroy'][text()='Delete']").click
    expect(page).to have_no_content('GOOG')

  end

  scenario 'adds an invalid stock and confirm it was not added ' do

    # Register, log out, and sign in again

    sign_up_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')
    click_link('Logout')
    sign_in_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')

    # Add a few stocks and check that they are visible under Watch List

    find(:css, "input[id$='stock_ticker']").set("Invalid")
    click_button 'Add'
    expect(page).to have_no_content('Invalid')

  end

  scenario 'adds a valid stock and check that the page is rendering data from API' do

    # Register, log out, and sign in again

    sign_up_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')
    click_link('Logout')
    sign_in_with 'valid@example.com', 'password'
    expect(page).to have_content('Logout')

    # Add a few stocks and check that they are visible under Watch List

    find(:css, "input[id$='stock_ticker']").set("aapl")
    click_button 'Add'
    expect(page).to have_link('AAPL')
    #puts page.body
    click_link('AAPL')


    # Check page for info, graph, and table

    expect(page).to have_content('Symbol: AAPL')
    expect(page).to have_content('Company Name: Apple Inc.')
    expect(page).to have_content('Exchange: Nasdaq Global Select')
    expect(page).to have_content('Industry: Computer Hardware')
    expect(page).to have_content('Website: http://www.apple.com')
    expect(page).to have_content('Description: Apple Inc is designs, manufactures and markets mobile communication and media devices and personal computers, and sells a variety of related software, services, accessories, networking solutions and third-party digital content and applications.')
    expect(page).to have_content('CEO: Timothy D. Cook')
    expect(page).to have_content('Issue Type: CS')
    expect(page).to have_content('Sector: Technology')
    
    # RoR with LazyHighCharts gem will blow up without valid data-- so we can just check the graph is there
    expect(page).to have_css('#stock_graph')

    # The value 65 for count is the magic number to check if table is properly populating with data from API
    # This value may need to change if during a certain time period, the number of data points in 3 months changes
    # Due to a difference in the number of days that the market is open during a given 3 month period
    expect(page).to have_css('#stock_table tr', :count => 65)

  end

   # Helper methods
   def sign_up_with(email, password)
    visit new_user_registration_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Sign up'
  end

   def sign_in_with(email, password)
    visit new_user_session_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Log in'
  end


end