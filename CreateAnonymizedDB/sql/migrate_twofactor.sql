update Gebruiker set Gebruiker_Is_TwoFactor_Ready = null, Gebruiker_TwoFactorSecret = null, Gebruiker_Is_TwoFactor_Smartphone = null

UPDATE [dbo].[Configuration]
SET [Value] = 'false'
WHERE [key] = 'twoFactorActive'
