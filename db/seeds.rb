# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'date'

puts 'Destroying database'
Conversation.destroy_all
Chat.destroy_all
Task.destroy_all
User.destroy_all

puts 'creating new users'

alexis = User.create!(email: 'alexis@test.com', password: '123abc')
brendan = User.create!(email: 'brendan@test.com', password: '123abc')

puts 'creating new chat'

Chat.create!(user: alexis)
Chat.create!(user: brendan)

puts 'creating new tasks'

tasks = [
  {
    title: 'Media campaign for new coffee flavour "Pomelo Americano"',
    content: 'Develop and implement a comprehensive media campaign for the new Pomelo Americano coffee flavour. This will include out-of-home (OOH) advertising and online engagement strategies. The budget for this campaign is S$10K, with OOH advertisements likely limited to physical stores. Consider setting up a popup at Raffles Place to attract office workers in their 20s to 30s. Focus the marketing efforts primarily on Instagram to reach the target demographic. Additionally, leverage relationships with Gushcloud influencers to promote the product and increase visibility.',
    priority: 'High',
    documents_path: ['documents/pdpc-guidelines.pdf', 'documents/Expedia.pdf', 'documents/ESGrelease.pdf'],
    due_date: Date.new(2024, 8, 20),
    reminder_datetime: DateTime.new(2024, 8, 20, 15, 30, 00),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Social media content calendar for Q3',
    content: 'Create a detailed social media content calendar for the third quarter, covering Facebook, Instagram, and TikTok. The content should focus on user-generated content, engaging visuals, and collaborations with local artists to promote our brand. Schedule posts in advance and ensure a consistent posting frequency. Incorporate feedback from the previous quarter’s review to improve engagement and reach. Coordinate with the design team to create high-quality images and videos that align with the brand’s aesthetic.',
    priority: 'Medium',
    documents_path: ['documents/Expedia.pdf'],
    due_date: Date.new(2024, 7, 1),
    reminder_datetime: DateTime.new(2024, 6, 30, 10, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Email marketing campaign for summer promotions',
    content: 'Plan and execute a series of email newsletters to promote summer discounts and new product launches. The campaign should be segmented to target different customer groups based on their preferences and purchase history. Design visually appealing emails that highlight the summer promotions and include exclusive offers for loyalty program members. Add photo shoot for the newsletters. Ensure each email contains a clear call-to-action to drive traffic to our website and increase sales. Monitor the performance of the campaign and adjust the strategy as needed to optimize results.',
    priority: 'Low',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 6, 15),
    reminder_datetime: DateTime.new(2024, 6, 14, 14, 0, 0),
    user: alexis,
    status: 'Complete'
  },
  {
    title: 'Collaborate with local influencers for product reviews',
    content: 'Identify and reach out to 10-15 local influencers within the food and beverage niche to collaborate on product reviews. Send them samples of the new coffee flavours and provide guidelines on the key points to highlight in their reviews. Track the engagement and reach of each influencer’s posts, and gather feedback on the product to improve future offerings. Develop long-term relationships with the influencers to ensure continued collaboration and brand advocacy.',
    priority: 'High',
    documents_path: ['documents/ESGrelease.pdf', 'documents/instructions.pdf', 'documents/minutes.pdf'],
    due_date: Date.new(2024, 7, 10),
    reminder_datetime: DateTime.new(2024, 7, 9, 9, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Plan and execute a coffee tasting event',
    content: 'Organize a coffee tasting event at the main store, inviting loyal customers and media representatives to sample the new flavours. Coordinate with the event planning team to handle logistics, including venue setup, catering, and guest list management. Prepare marketing materials to promote the event and ensure media coverage to maximize exposure. Capture photos and videos during the event for use in future marketing campaigns and social media posts. Collect feedback from attendees to gauge their reactions and preferences.',
    priority: 'Low',
    documents_path: ['documents/faqs.pdf'],
    due_date: Date.new(2024, 8, 5),
    reminder_datetime: DateTime.new(2024, 8, 4, 16, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Update website with new product information',
    content: 'Collaborate with the web development team to update the website with information about new coffee flavours and current promotions. Ensure the content is SEO optimized to improve search engine rankings and drive organic traffic. Use high-quality photos and detailed product descriptions to entice customers. Regularly check the website for any issues and make necessary updates to maintain a smooth user experience. Analyze web traffic data to assess the impact of the updates and identify areas for further improvement.',
    priority: 'Medium',
    documents_path: ['documents/ESGrelease.pdf', 'documents/Expedia.pdf'],
    due_date: Date.new(2024, 7, 25),
    reminder_datetime: DateTime.new(2024, 7, 24, 11, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Conduct market research for new product ideas',
    content: 'Design and distribute surveys to gather customer feedback on potential new coffee flavours and products. Add product photos in survey. Use a variety of channels, including email, social media, and in-store questionnaires, to reach a broad audience. Analyze the survey data to identify trends and preferences, and prepare a comprehensive report with recommendations for new product development. Share the findings with the product development team to inform their decisions and ensure that new products align with customer desires.',
    priority: 'Low',
    documents_path: ['documents/claims-guide.pdf'],
    due_date: Date.new(2024, 9, 1),
    reminder_datetime: DateTime.new(2024, 8, 31, 17, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Develop partnership with local cafes',
    content: 'Reach out to local cafes to establish partnerships for cross-promotional opportunities. Propose collaborative events, co-branded products, and joint marketing efforts to increase brand visibility. Arrange meetings with cafe owners to discuss potential deals and finalize agreements. Track the performance of these partnerships and adjust strategies as necessary to ensure mutual benefits and sustained collaboration.',
    priority: 'Medium',
    documents_path: ['documents/faqs.pdf'],
    due_date: Date.new(2024, 7, 15),
    reminder_datetime: DateTime.new(2024, 7, 14, 10, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Launch loyalty program enhancements',
    content: 'Plan and execute the launch of new enhancements to the customer loyalty program. Develop marketing materials to promote the new benefits and features to existing members and attract new sign-ups. Coordinate with the IT team to ensure the enhancements are properly integrated into the existing system. Monitor the impact of the enhancements on customer engagement and retention, and gather feedback for further improvements.',
    priority: 'High',
    documents_path: ['documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 6, 30),
    reminder_datetime: DateTime.new(2024, 6, 29, 15, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Prepare Q2 marketing performance report',
    content: 'Compile and analyze data from various marketing campaigns executed in Q2 to prepare a comprehensive performance report. Include metrics such as ROI, engagement rates, and customer feedback. Identify successful strategies and areas for improvement. Present the findings to the management team and suggest actionable insights for Q3 marketing plans. Ensure the report is visually appealing and easy to understand, with clear graphs and summaries.',
    priority: 'Medium',
    documents_path: ['documents/minutes.pdf'],
    due_date: Date.new(2024, 7, 5),
    reminder_datetime: DateTime.new(2024, 7, 4, 14, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Redesign product packaging',
    content: 'Collaborate with the design team to create new packaging designs and photos for the coffee products that align with the brand image and appeal to the target audience. Conduct market research to gather customer preferences and feedback on current packaging. Ensure the new designs are practical, eco-friendly, and compliant with industry standards. Present the final designs to the management team for approval and coordinate with suppliers for production.',
    priority: 'Low',
    documents_path: ['documents/instructions.pdf'],
    due_date: Date.new(2024, 8, 30),
    reminder_datetime: DateTime.new(2024, 8, 29, 11, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Organize photoshoot for new product line',
    content: 'Plan and execute a professional photoshoot to capture high-quality images of the new coffee product line. Work with a photographer and stylist to create visually appealing shots that highlight the products. Ensure the photos align with the brand’s aesthetic and can be used across various marketing channels, including social media, the website, and promotional materials. Coordinate logistics, such as location, props, and models, to ensure a smooth and successful photoshoot.',
    priority: 'High',
    documents_path: ['documents/checklist.pdf'],
    due_date: Date.new(2024, 7, 20),
    reminder_datetime: DateTime.new(2024, 7, 19, 13, 0, 0),
    user: alexis,
    status: 'Incomplete'
  },
  {
    title: 'Finish Q3 audit for RE Bank',
    content: 'Work off Q2 audit findings to identify if recommendations had been implemented. Contact Joseph from Data team to get latest industry risk findings. Ensure I have latest cashflow statements (check with Alice). Remember to add in new section in observation notes as requested by RE Bank manager.',
    priority: 'High',
    documents_path: ['documents/pdpc-guidelines.pdf', 'documents/Expedia.pdf', 'documents/ESGrelease.pdf'],
    due_date: Date.new(2024, 8, 20),
    reminder_datetime: DateTime.new(2024, 8, 20, 15, 30, 00),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Prepare audit report for Global Tech Ltd.',
    content: 'Compile the findings from the audit of Global Tech Ltd. Ensure all sections are thoroughly reviewed and provide clear recommendations. Follow up with the IT department to validate the data security measures in place. Arrange a meeting with the finance team to discuss discrepancies found in the financial statements.',
    priority: 'High',
    documents_path: ['documents/checklist.pdf', 'documents/minutes.pdf'],
    due_date: Date.new(2024, 7, 15),
    reminder_datetime: DateTime.new(2024, 7, 14, 10, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Review compliance with new financial regulations',
    content: 'Evaluate the company adherence to the latest financial regulations. Coordinate with the compliance officer to get updates on the regulatory changes. Cross-check the compliance checklist and ensure all points are covered. Prepare a summary report highlighting any non-compliance issues.',
    priority: 'Medium',
    documents_path: ['documents/Expedia.pdf', 'documents/claims-guide.pdf'],
    due_date: Date.new(2024, 7, 25),
    reminder_datetime: DateTime.new(2024, 7, 24, 14, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Conduct risk assessment for XYZ Corporation',
    content: 'Perform a thorough risk assessment for XYZ Corporation. Identify potential financial and operational risks. Consult with the risk management team to discuss mitigation strategies. Document all findings and ensure the report is aligned with the company risk management framework.',
    priority: 'High',
    documents_path: ['documents/instructions.pdf', 'documents/Expedia.pdf'],
    due_date: Date.new(2024, 8, 10),
    reminder_datetime: DateTime.new(2024, 8, 9, 13, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Verify asset valuation for DEF Industries',
    content: 'Check the accuracy of asset valuations for DEF Industries. Liaise with the valuation experts to ensure the valuations are up-to-date and compliant with industry standards. Confirm that all necessary documentation is available and properly filed. Prepare a detailed report on the findings.',
    priority: 'Low',
    documents_path: ['documents/faqs.pdf', 'documents/checklist.pdf'],
    due_date: Date.new(2024, 8, 5),
    reminder_datetime: DateTime.new(2024, 8, 4, 16, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Audit internal controls for GHI Enterprises',
    content: 'Examine the internal control systems of GHI Enterprises. Verify the effectiveness of the controls and identify any weaknesses. Meet with the internal audit team to discuss their findings and incorporate them into the final report. Recommend improvements where necessary.',
    priority: 'High',
    documents_path: ['documents/claims-guide.pdf', 'documents/ESGrelease.pdf'],
    due_date: Date.new(2024, 7, 30),
    reminder_datetime: DateTime.new(2024, 7, 29, 11, 0, 0),
    user: brendan,
    status: 'Complete'
  },
  {
    title: 'Review quarterly financial statements for JKL Ltd.',
    content: 'Analyze the quarterly financial statements of JKL Ltd. Check for accuracy and compliance with accounting standards. Highlight any significant variances or anomalies. Prepare a summary of the key findings and share it with the finance team for their review.',
    priority: 'Medium',
    documents_path: ['documents/instructions.pdf', 'documents/minutes.pdf'],
    due_date: Date.new(2024, 7, 20),
    reminder_datetime: DateTime.new(2024, 7, 19, 15, 0, 0),
    user: brendan,
    status: 'Complete'
  },
  {
    title: 'Conduct due diligence for MNO merger',
    content: 'Perform a comprehensive due diligence review for the upcoming merger between MNO and PQR Inc. Evaluate the financial health and operational efficiency of both companies. Identify any potential risks or red flags. Prepare a detailed report to support the merger decision-making process.',
    priority: 'High',
    documents_path: ['documents/checklist.pdf', 'documents/claims-guide.pdf'],
    due_date: Date.new(2024, 8, 15),
    reminder_datetime: DateTime.new(2024, 8, 14, 10, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Assess cybersecurity measures for STU Corp.',
    content: 'Evaluate the cybersecurity measures in place at STU Corp. Conduct interviews with the IT security team to understand their protocols and practices. Review recent cybersecurity incidents and assess the company response. Provide recommendations to enhance security and prevent future breaches.',
    priority: 'Medium',
    documents_path: ['documents/faqs.pdf', 'documents/minutes.pdf'],
    due_date: Date.new(2024, 8, 25),
    reminder_datetime: DateTime.new(2024, 8, 24, 11, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Prepare annual audit plan',
    content: 'Develop the annual audit plan, outlining the scope and objectives for the upcoming year. Coordinate with the audit committee to ensure alignment with the organization strategic goals. Identify key areas of focus and allocate resources accordingly. Submit the plan for approval and communicate it to the relevant stakeholders.',
    priority: 'High',
    documents_path: ['documents/claims-guide.pdf', 'documents/ESGrelease.pdf'],
    due_date: Date.new(2024, 7, 31),
    reminder_datetime: DateTime.new(2024, 7, 30, 14, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Evaluate investment portfolio for VWX Investments',
    content: 'Assess the performance of VWX Investments portfolio. Analyze the returns on investment and compare them with industry benchmarks. Identify underperforming assets and provide recommendations for portfolio rebalancing. Prepare a comprehensive report for the investment committee.',
    priority: 'Medium',
    documents_path: ['documents/Expedia.pdf', 'documents/faqs.pdf'],
    due_date: Date.new(2024, 8, 18),
    reminder_datetime: DateTime.new(2024, 8, 17, 13, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Audit payroll processes for XYZ Inc.',
    content: 'Review the payroll processes at XYZ Inc. Ensure compliance with labor laws and regulations. Verify the accuracy of payroll records and identify any discrepancies. Meet with the HR department to discuss findings and suggest improvements to enhance payroll accuracy and efficiency.',
    priority: 'High',
    documents_path: ['documents/instructions.pdf', 'documents/pdpc-guidelines.pdf'],
    due_date: Date.new(2024, 8, 1),
    reminder_datetime: DateTime.new(2024, 7, 31, 10, 0, 0),
    user: brendan,
    status: 'Incomplete'
  },
  {
    title: 'Investigate fraud allegations at ABC Corp.',
    content: 'Conduct a thorough investigation into the fraud allegations at ABC Corp. Gather and analyze evidence to substantiate the claims. Interview relevant employees and stakeholders to gather information. Prepare a detailed report outlining the findings and recommendations for corrective actions.',
    priority: 'High',
    documents_path: ['documents/claims-guide.pdf', 'documents/minutes.pdf'],
    due_date: Date.new(2024, 8, 12),
    reminder_datetime: DateTime.new(2024, 8, 11, 11, 0, 0),
    user: brendan,
    status: 'Incomplete'
  }
]

tasks.each do |attributes|
  task = Task.new(attributes.except(:documents_path))
  attributes[:documents_path].each do |path|
    task.documents.attach(
      io: File.open(path),
      filename: "#{path}",
      content_type: 'application/pdf',
      identify: false
    )
    task.save!
    puts "Created #{task.title}"
  end
end
