# Terraform

## Anleitung zur Replikation des Projekts

### AWS-Konto erstellen

1. Besuchen Sie die AWS-Website: [https://aws.amazon.com/](https://aws.amazon.com/)
2. Klicken Sie auf "Create an AWS Account".
3. Folgen Sie den Anweisungen zur Erstellung eines neuen AWS-Kontos.
4. Nach der Erstellung des Kontos melden Sie sich bei der AWS Management Console an.

### S3-Bucket erstellen

1. Melden Sie sich bei der AWS Management Console an.
2. Gehen Sie zu "Services" und wählen Sie "S3" unter "Storage".
3. Klicken Sie auf "Create bucket".
4. Geben Sie einen eindeutigen Namen für den Bucket ein (z.B. `myawsbucket061100`).
5. Wählen Sie die gewünschte Region aus (z.B. `eu-north-1`).
6. Klicken Sie auf "Create bucket".

### Projekt bereitstellen

1. Klonen Sie das Repository:
   ```bash
   git clone https://github.com/omaraldulimay/Cloud-Programming-Projekt.git
   cd Cloud-Programming-Projekt
   ```

2. Installieren Sie Terraform: [Terraform Installationsanleitung](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3. Initialisieren Sie das Terraform-Projekt:
   ```bash
   terraform init
   ```

4. Überprüfen Sie den Terraform-Plan:
   ```bash
   terraform plan
   ```

5. Wenden Sie den Terraform-Plan an:
   ```bash
   terraform apply
   ```

6. Bestätigen Sie die Anwendung des Plans, indem Sie `yes` eingeben.

7. Nach erfolgreicher Bereitstellung können Sie die erstellten Ressourcen in der AWS Management Console überprüfen.


### CloudFront-Distribution erstellen

1. Melden Sie sich bei der AWS Management Console an.
2. Gehen Sie zu "Services" und wählen Sie "CloudFront" unter "Networking & Content Delivery".
3. Klicken Sie auf "Create Distribution".
4. Wählen Sie "Web" als Verteilungsmethode.
5. Geben Sie den Namen des S3-Buckets ein, den Sie als Ursprungsort verwenden möchten (z.B. `myawsbucket061100`).
6. Konfigurieren Sie die gewünschten Einstellungen für die Verteilung.
7. Klicken Sie auf "Create Distribution".
8. Warten Sie, bis der Status der Verteilung auf "Deployed" wechselt.


### Verknüpfung der HTML-Datei mit dem S3-Bucket

1. Melden Sie sich bei der AWS Management Console an.
2. Gehen Sie zu "Services" und wählen Sie "S3" unter "Storage".
3. Suchen Sie den erstellten S3-Bucket (z.B. `myawsbucket061100`).
4. Klicken Sie auf den Bucket-Namen, um den Inhalt anzuzeigen.
5. Klicken Sie auf "Upload" und wählen Sie die HTML-Datei (z.B. `index.html`) aus, die Sie hochladen möchten.
6. Klicken Sie auf "Upload", um die Datei in den S3-Bucket hochzuladen.
7. Stellen Sie sicher, dass die Datei öffentlich zugänglich ist, indem Sie die Berechtigungen entsprechend konfigurieren.


   ### Zugriff auf die HTML-Datei über die CloudFront-Domain

1. Nach der Bereitstellung des Projekts wird eine CloudFront-Domain erstellt.
2. Gehen Sie zur AWS Management Console und navigieren Sie zu "CloudFront" unter "Networking & Content Delivery".
3. Suchen Sie die erstellte Distribution und kopieren Sie den Domainnamen (z.B. `d1pqr0eof9iean.cloudfront.net`).
4. Öffnen Sie einen Webbrowser und geben Sie den kopierten Domainnamen ein, um auf die bereitgestellte HTML-Datei zuzugreifen.
