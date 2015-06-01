function(input, output) {
        usePackage("XML")
        usePackage("ggplot2")
        usePackage("downloader")

        URL <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"

        data <- readGoogleSheet(URL)
        data$Ethnicity <- as.factor(data$Ethnicity)
        data$Gender <- as.factor(data$Gender)
        #reorder factor levels for Gender
        data <- within(data, Gender <- factor(Gender,levels=names(sort(table(Gender), decreasing=TRUE))))
        data$Area <- as.factor(data$'Area at Buffer')
        output$table <- renderDataTable(data)

        output$ethnicityPlot <- renderPlot({
            qplot(Ethnicity, data=data, geom="bar", fill=Gender)  +
            theme(axis.text.x=element_text(angle = 90, vjust = 0.5)) +
            xlab("") + ylab("") +
            ggtitle("Applicants by Gender and Ethnicity")
        },)

        output$genderPlot <- renderPlot({
           qplot(Gender, fill=Gender,data=data) +
            facet_wrap( ~ Area, nrow=3) +
            ggtitle("Applicants Gender")
        }, height=600, units='px')
}
