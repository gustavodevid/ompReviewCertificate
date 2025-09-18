{**
 * @file plugins/generic/reviewCertificate/templates/reviewerSubmissions.tpl
 *
 * Copyright (c) 2024 Gustavo David Cesário
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Template que lista as avaliações concluídas pelo usuário no painel principal.
 *
 * @author Gustavo David gustavo.cesariosilva15@gmail.com
 * @version 1.0
 * @date 2025-09-18
 *}

{block name="reviewer"}
    <div class="pkp_page_content">
        <h2>Histórico de revisões</h2>

        <div class="pkp_list_panel">
            {foreach from=$reviewedSubmissions item=submission}
                <div class="pkpListPanel__item">
                    <div class="pkpListPanel__itemSummary">
                        <strong>{$submission.title|escape}</strong> — {$submission.id}
                    </div>
                    <div class="pkpListPanel__itemActions">
                        <button class="pkpButton pkpButton--primary generate-pdf-btn" data-submission-id="{$submission.id}"
                            data-submission-title="{$submission.title|escape}"
                            data-reviewer-name="{$submission.reviewData.reviewerFullName}"
                            data-press-name="{$currentContext->getLocalizedName()}"
                            data-date-br="{$submission.reviewData.dateCompletedBR}"
                            data-date-us="{$submission.reviewData.dateCompletedUS}"
                            data-ifpb-logo="{$submission.reviewData.ifpbLogoPath}"
                            data-press-logo="{$submission.reviewData.pressLogoPath}"
                            data-press-signature="{$submission.reviewData.pressMasterSignature}"
                            data-press-name-complete="{$submission.reviewData.pressMasterFullName}"
                            onclick="gerarPDF('certificadoModal-{$submission.id}', 'modal-{$submission.id}')">
                            Gerar PDF
                        </button>
                    </div>
                </div>

                <div id="container-{$submission.id}" style="display: none;">
                    <div id="modal-{$submission.id}" style="
                        position: fixed; 
                        top: 0; 
                        right: 0; 
                        bottom: 0; 
                        left: 0; 
                        overflow: auto; 
                        outline: 0; 
                        z-index: 1050; 
                        visibility: hidden; 
                        display: none;">

                        <div id="content-{$submission.id}" style="
                            position: relative;
                            margin: 10px;">

                            <div id="modal-content-{$submission.id}" style="
                                max-width: 100%;
                                box-sizing: border-box;
                                position: relative;
                                z-index: 100;
                                background-color: #fff; 
                                box-shadow: 0 3px 9px rgba(0, 0, 0, 0.5); 
                                border-radius: 0.3rem; 
                                transform: scale(0.95);">

                                <div id="modal-body-{$submission.id}" style="
                                    max-height: calc(100% - 100px); 
                                    overflow-y: auto;">
                                    
                                    {* Usei a versão simplificada com tabelas para garantir a geração do PDF *}
                                    <div id="certificadoModal-{$submission.id}">
                                        <table width="100%" style="border: 10px solid #00569e; height: 95%; border-collapse: collapse;">
                                            <tr>
                                                <td style="padding: 40px; text-align: center; vertical-align: top;">
                                                    <table width="100%" style="border: 0;">
                                                        <tr>
                                                            <td style="width: 70%; text-align: center;">
                                                                <h2 style="margin-right: 9px; font-family: sans-serif; color: #002b4f;">INSTITUTO FEDERAL DE EDUCAÇÃO CIÊNCIA</h2>
                                                                <h2 style="font-family: sans-serif; color: #002b4f;">E TECNOLOGIA DA PARAÍBA</h2>
                                                            </td>
                                                            <td style="width: 30%; text-align: right;">
                                                                <img src="{$submission.reviewData.ifpbLogoPath|escape}" style="width: 100px; height: auto;">
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <div style="margin-top: 38px; text-align: center; font-family: sans-serif;">
                                                        <h3 style="font-weight: bold; font-size: 24px;">Declaração do Revisor Ad Hoc</h3>
                                                        <div style="padding-top: 10px; width: 80%; margin: 0 auto; text-align: justify; font-size: 18px; line-height: 1.6;">
                                                            <p>
                                                                Declaramos, para os devidos fins, que <strong>{$submission.reviewData.reviewerFullName|escape}</strong> desempenhou
                                                                a função de avaliador(a) ad hoc do artigo científico identificado pelo código
                                                                <strong>{$submission.reviewData.submissionId|escape}</strong>, a convite do Comitê Editorial da
                                                                <strong>{$currentContext->getLocalizedName()|escape}</strong>, no dia {$submission.reviewData.dateCompletedBR|escape}.
                                                            </p>
                                                        </div>
                                                        <h3 style="font-weight: bold; margin-top: 30px; font-size: 24px;">Ad Hoc Reviewer Statement</h3>
                                                        <div style="padding-top: 10px; width: 80%; margin: 0 auto; text-align: justify; font-size: 18px; line-height: 1.6;">
                                                            <p>
                                                                We now declare that <strong>{$submission.reviewData.reviewerFullName|escape}</strong> served
                                                                as an ad hoc reviewer for the scientific article identified by the code
                                                                <strong>{$submission.reviewData.submissionId|escape}</strong>, at the invitation of the Editorial Committee of the
                                                                <strong>{$currentContext->getLocalizedName()|escape}</strong>, on {$submission.reviewData.dateCompletedUS|escape}.
                                                            </p>
                                                        </div>
                                                        <div style="margin-top: 50px; text-align: right; margin-right: 40px; font-size: 16px;">
                                                            <p>
                                                                João Pessoa, Brasil/Brazil, {$submission.reviewData.dateCompletedBR|escape}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 40px; text-align: center; vertical-align: bottom;">
                                                    <div style="text-align: center;">
                                                        {if $submission.reviewData.pressMasterSignature}
                                                            <img src="{$submission.reviewData.pressMasterSignature|escape}" alt="Assinatura" style="width: 200px; height: auto;"><br>
                                                        {/if}
                                                        <strong>{$submission.reviewData.pressMasterFullName|escape}</strong><br>
                                                        <span style="font-size: 12px;">Diretor-Executivo da Editora IFPB/ Executive Director of IFPB Publishing House</span>
                                                    </div>
                                                    {if $submission.reviewData.pressLogoPath}
                                                        <div style="margin-top: 30px;">
                                                            <img src="{$submission.reviewData.pressLogoPath|escape}" style="max-width: 150px; max-height: 70px; width: auto; height: auto;">
                                                        </div>
                                                    {/if}
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div> 
                            </div> 
                        </div> 
                    </div> 
                </div> 

            {foreachelse}
                <div class="pkpListPanel__item pkpListPanel__item--empty">
                     Nada encontrado.
                </div>
            {/foreach}
        </div>
    </div>

    <script src="https://rawgit.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <script>
        {literal}
        function gerarPDF(certificadoId, modalId) {
            var valorDoEditor = document.getElementById(certificadoId);
            var options = {
                margin: 10,
                filename: 'documento.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
                pagebreak: { mode: ['avoid-all'] }
            };
            html2pdf(valorDoEditor, options);
            // Ocultar o modal (opcional, já que ele nunca é mostrado)
            // $('#' + modalId).modal('hide');
        }
        {/literal}
    </script>
{/block}