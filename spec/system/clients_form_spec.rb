require 'rails_helper'

RSpec.describe "Client Management", type: :system do
  let(:admin_user) { create(:user, role: :admin) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  it "shows client list with name and contact" do
    create(:client, client_name: "Alpha", contact_info: "alpha@example.com")
    visit clients_path

    expect(page).to have_content("Client list")
    expect(page).to have_content("Alpha")
    expect(page).to have_content("alpha@example.com")
  end

  it "creates a new client" do
    visit new_client_path

    fill_in "Client name", with: "Beta Co."
    fill_in "Contact info", with: "beta@co.com"
    click_button "Create Client"

    expect(page).to have_content("Client list")
    expect(page).to have_content("Beta Co.")
  end

  it "edits a client" do
    client = create(:client, client_name: "Old Client")
    visit clients_path

    visit edit_client_path(client)

    fill_in "Client name", with: "Updated Client"
    click_button "Update Client"

    expect(page).to have_content("Updated Client")
    expect(page).not_to have_content("Old Client")
  end

  it "deletes a client with confirm dialog", js: true do
    client = create(:client, client_name: "DeleteMe")
    visit clients_path

    find("tr", text: "DeleteMe").click_button "delete-client-button"

    accept_confirm do
      find("tr", text: "DeleteMe").find("button").click
    end

    expect(page).not_to have_content("DeleteMe")
  end
end
