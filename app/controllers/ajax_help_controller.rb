class AjaxHelpController < ApplicationController

  PAGES = [:index, :tour, :public, :accounts, :searching, :uploading, :troubleshooting,
    :modification, :notes, :collaboration, :privacy, :publishing, :api]

  PAGE_TITLES = {
    :index            => 'Introduction',
    :tour             => 'Guided Tour',
    :public           => 'The Public Catalog',
    :accounts         => 'Adding Accounts',
    :searching        => 'Searching Documents and Data',
    :uploading        => 'Uploading Documents',
    :troubleshooting  => 'Troubleshooting Failed Uploads',
    :modification     => 'Document Modification',
    :privacy          => 'Privacy',
    :collaboration    => 'Collaboration',
    :notes            => 'Editing Notes and Sections',
    :publishing       => 'Publishing &amp; Embedding',
    :api              => 'API'
  }

  layout false

  def contact_us
    return bad_request unless params[:message]
    LifecycleMailer.deliver_contact_us(current_account, params)
    json nil
  end

  PAGES.each do |resource|
    class_eval "def #{resource}; markdown(:#{resource}); end"
  end

  private

  HELP_DIRECTORY = "#{Rails.root}/app/views/help"

  def help_for_language( language, resource )
    "#{HELP_DIRECTORY}/#{language}/#{resource}.markdown"
  end

  def links_for_language( language, resource )
    "#{HELP_DIRECTORY}/#{language}/#{resource}_ajax_links.markdown"
  end

  def markdown(resource)
    language = logged_in? ? current_account.language : DC::Language::DEFAULT
    if ! File.exists?( help_for_language( language, resource ) ) && language != DC::Language::DEFAULT
      language = DC::Language::DEFAULT
    end
    render not_found and return unless File.exists?( help_for_language( language, resource ) )

    contents = File.read( help_for_language( language, resource ) )
    links = File.exists?( links_for_language( language, resource ) ) ?
      File.read( links_for_language( language, resource ) ) : ""
    render :text => RDiscount.new(contents+links).to_html, :type => :html
  end

end
